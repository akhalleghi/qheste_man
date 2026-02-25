import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('برنامه اقساط من نمایش داده می شود', (WidgetTester tester) async {
    await tester.pumpWidget(const MyInstallmentsApp());

    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تنظیمات'), findsOneWidget);
  });
}
