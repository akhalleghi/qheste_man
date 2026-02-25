import 'dart:math';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../models/finance_items.dart';

class ReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final DeviceCalendarPlugin _calendar = DeviceCalendarPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(init);
    _initialized = true;
  }

  static Future<void> scheduleForInstallment(
    InstallmentItem installment,
  ) async {
    await initialize();
    final schedule = _buildSchedule(installment);

    if (installment.notifyPush) {
      await _requestNotificationPermission();
      for (var i = 0; i < schedule.length; i++) {
        final item = schedule[i];
        final trigger = item.dueDate.subtract(const Duration(hours: 9));
        if (trigger.isBefore(DateTime.now())) continue;
        final id = _notificationId(installment.id, i);
        await _notifications.zonedSchedule(
          id,
          'یادآور قسط',
          '${installment.title} - ${item.label}',
          tz.TZDateTime.from(trigger, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'installments_channel',
              'Installment Reminders',
              channelDescription: 'Installment due reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
        );
      }
    }

    if (installment.notifyCalendar) {
      await _insertCalendarEvents(installment, schedule);
    }
  }

  static Future<bool> sendTestNotification() async {
    await initialize();
    await _requestNotificationPermission();
    await _notifications.show(
      987654,
      'تست نوتیفیکیشن',
      'این یک اعلان آزمایشی از برنامه اقساط است.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'installments_channel',
          'Installment Reminders',
          channelDescription: 'Installment due reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    return true;
  }

  static Future<void> _requestNotificationPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> _insertCalendarEvents(
    InstallmentItem installment,
    List<_DueItem> schedule,
  ) async {
    final status = await Permission.calendarWriteOnly.request();
    if (!status.isGranted) {
      final fallback = await Permission.calendarFullAccess.request();
      if (!fallback.isGranted) return;
    }

    final calendarsResult = await _calendar.retrieveCalendars();
    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) return;
    final target = calendars.firstWhere(
      (c) => c.isReadOnly != true,
      orElse: () => calendars.first,
    );

    for (var i = 0; i < schedule.length; i++) {
      final item = schedule[i];
      if (item.dueDate.isBefore(DateTime.now())) continue;
      final event = Event(
        target.id,
        title: 'سررسید قسط ${installment.title}',
        description:
            'مبلغ: ${item.amount.toStringAsFixed(0)} تومان - ${item.label}',
        start: tz.TZDateTime.from(item.dueDate, tz.local),
        end: tz.TZDateTime.from(
          item.dueDate.add(const Duration(minutes: 30)),
          tz.local,
        ),
        reminders: [Reminder(minutes: 24 * 60)],
      );
      await _calendar.createOrUpdateEvent(event);
    }
  }

  static List<_DueItem> _buildSchedule(InstallmentItem installment) {
    final result = <_DueItem>[];
    final firstDue = _parseJalali(installment.firstDueDate);
    final monthlyAmount = _toNum(installment.monthlyInstallmentAmount);
    final annualRate = installment.annualInterestPercent / 100;
    var remaining = _toNum(installment.totalAmount);
    var periodStartPrincipal = remaining;
    var monthsInCurrentPeriod = 0;

    for (var i = 0; i < installment.durationMonths; i++) {
      final dueJalali = firstDue.addMonths(i);
      final dueDate = dueJalali.toDateTime();
      var amount = monthlyAmount;
      remaining = max(0, remaining - monthlyAmount);
      monthsInCurrentPeriod += 1;

      if (installment.hasAnnualFee) {
        final isYearBoundary = monthsInCurrentPeriod == 12;
        final isLastInstallment = i == installment.durationMonths - 1;
        if (isYearBoundary || isLastInstallment) {
          amount +=
              periodStartPrincipal * annualRate * (monthsInCurrentPeriod / 12);
          periodStartPrincipal = remaining;
          monthsInCurrentPeriod = 0;
        }
      }

      result.add(
        _DueItem(dueDate: dueDate, amount: amount, label: 'قسط ${i + 1}'),
      );
    }
    return result;
  }

  static int _notificationId(String installmentId, int index) {
    return (installmentId.hashCode ^ index) & 0x7fffffff;
  }

  static double _toNum(String raw) {
    final clean = raw.replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0;
  }

  static Jalali _parseJalali(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return Jalali.now();
    final y = int.tryParse(parts[0]) ?? Jalali.now().year;
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    return Jalali(y, m, d);
  }
}

class _DueItem {
  const _DueItem({
    required this.dueDate,
    required this.amount,
    required this.label,
  });

  final DateTime dueDate;
  final double amount;
  final String label;
}
