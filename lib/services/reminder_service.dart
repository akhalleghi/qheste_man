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

  static const _eventMarkerPrefix = 'bizto_installment:';
  static const _eventRefSeparator = '::';

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _configureLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const init = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(init);
    _initialized = true;
  }

  /// Re-schedules push/calendar reminders for all stored installments.
  static Future<List<InstallmentItem>> rescheduleAll(
    List<InstallmentItem> installments,
  ) async {
    await initialize();
    final updated = <InstallmentItem>[];
    for (final installment in installments) {
      updated.add(await scheduleForInstallment(installment));
    }
    return updated;
  }

  /// Schedules reminders and returns installment with updated calendar refs.
  static Future<InstallmentItem> scheduleForInstallment(
    InstallmentItem installment,
  ) async {
    await initialize();
    await _cancelInstallmentNotifications(installment);
    await _removeCalendarEvents(installment);

    final schedule = _buildSchedule(installment);
    var result = installment.copyWith(calendarEventRefs: const []);

    if (installment.notifyPush) {
      await _requestNotificationPermission();
      await _requestExactAlarmPermissionIfNeeded();
      final scheduleMode = await _resolveAndroidScheduleMode();

      for (var i = 0; i < schedule.length; i++) {
        if (installment.paidInstallmentIndexes.contains(i)) continue;

        final item = schedule[i];
        final trigger = _reminderTriggerFor(item.dueDate);
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
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
        );
      }
    }

    if (installment.notifyCalendar) {
      final refs = await _syncCalendarEvents(installment, schedule);
      result = result.copyWith(calendarEventRefs: refs);
    }

    return result;
  }

  /// Cancels notifications and removes calendar events for one installment.
  static Future<void> cancelForInstallment(InstallmentItem installment) async {
    await initialize();
    await _cancelInstallmentNotifications(installment);
    await _removeCalendarEvents(installment);
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

  static void _configureLocalTimeZone() {
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Tehran'));
    } catch (_) {
      // Keep package default if lookup fails.
    }
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

  static Future<void> _requestExactAlarmPermissionIfNeeded() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    final canSchedule = await android.canScheduleExactNotifications();
    if (canSchedule == false) {
      await android.requestExactAlarmsPermission();
    }
  }

  static Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final canSchedule = await android.canScheduleExactNotifications();
    if (canSchedule == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static Future<void> _cancelInstallmentNotifications(
    InstallmentItem installment,
  ) async {
    for (var i = 0; i < installment.durationMonths; i++) {
      await _notifications.cancel(_notificationId(installment.id, i));
    }
  }

  static DateTime _reminderTriggerFor(DateTime dueDate) {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDay.subtract(const Duration(days: 1)).add(const Duration(hours: 9));
  }

  static Future<bool> _ensureCalendarPermissions() async {
    final pluginResult = await _calendar.requestPermissions();
    if (pluginResult.isSuccess && pluginResult.data == true) {
      return true;
    }

    var write = await Permission.calendarWriteOnly.request();
    if (write.isGranted) return true;

    final full = await Permission.calendarFullAccess.request();
    return full.isGranted;
  }

  static Future<Calendar?> _pickWritableCalendar() async {
    final calendarsResult = await _calendar.retrieveCalendars();
    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) return null;

    return calendars.firstWhere(
      (c) => c.isReadOnly != true,
      orElse: () => calendars.first,
    );
  }

  static Future<void> _removeCalendarEvents(InstallmentItem installment) async {
    if (!await _ensureCalendarPermissions()) return;

    for (final ref in installment.calendarEventRefs) {
      final parsed = _parseEventRef(ref);
      if (parsed == null) continue;
      await _calendar.deleteEvent(parsed.calendarId, parsed.eventId);
    }

    await _removeOrphanCalendarEvents(installment);
  }

  /// Reads calendar events in the loan date range and removes stale app events.
  static Future<void> _removeOrphanCalendarEvents(
    InstallmentItem installment,
  ) async {
    final calendar = await _pickWritableCalendar();
    if (calendar?.id == null) return;

    final schedule = _buildSchedule(installment);
    if (schedule.isEmpty) return;

    final start = schedule.first.dueDate.subtract(const Duration(days: 2));
    final end = schedule.last.dueDate.add(const Duration(days: 2));
    final marker = '$_eventMarkerPrefix${installment.id}:';

    final eventsResult = await _calendar.retrieveEvents(
      calendar!.id,
      RetrieveEventsParams(startDate: start, endDate: end),
    );
    final events = eventsResult.data ?? [];
    for (final event in events) {
      final description = event.description ?? '';
      if (!description.contains(marker)) continue;
      final eventId = event.eventId;
      if (eventId == null) continue;
      await _calendar.deleteEvent(calendar.id, eventId);
    }
  }

  static Future<List<String>> _syncCalendarEvents(
    InstallmentItem installment,
    List<_DueItem> schedule,
  ) async {
    if (!await _ensureCalendarPermissions()) return const [];

    final calendar = await _pickWritableCalendar();
    if (calendar?.id == null) return const [];

    final calendarId = calendar!.id!;
    final refs = <String>[];

    for (var i = 0; i < schedule.length; i++) {
      if (installment.paidInstallmentIndexes.contains(i)) continue;

      final item = schedule[i];
      if (item.dueDate.isBefore(DateTime.now())) continue;

      final start = tz.TZDateTime.from(item.dueDate, tz.local);
      final end = tz.TZDateTime.from(
        item.dueDate.add(const Duration(minutes: 30)),
        tz.local,
      );

      final event = Event(
        calendarId,
        title: 'سررسید قسط ${installment.title}',
        description:
            '$_eventMarkerPrefix${installment.id}:$i\n'
            'مبلغ: ${item.amount.toStringAsFixed(0)} تومان - ${item.label}',
        start: start,
        end: end,
        reminders: [Reminder(minutes: 24 * 60)],
      );

      final createResult = await _calendar.createOrUpdateEvent(event);
      final eventId = createResult?.data;
      if (eventId != null && eventId.isNotEmpty) {
        refs.add(_formatEventRef(calendarId, eventId));
      }
    }

    return refs;
  }

  static String _formatEventRef(String calendarId, String eventId) {
    return '$calendarId$_eventRefSeparator$eventId';
  }

  static _CalendarEventRef? _parseEventRef(String ref) {
    final separatorIndex = ref.indexOf(_eventRefSeparator);
    if (separatorIndex <= 0 || separatorIndex >= ref.length - 2) {
      return null;
    }
    return _CalendarEventRef(
      calendarId: ref.substring(0, separatorIndex),
      eventId: ref.substring(separatorIndex + _eventRefSeparator.length),
    );
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

class _CalendarEventRef {
  const _CalendarEventRef({required this.calendarId, required this.eventId});

  final String calendarId;
  final String eventId;
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
