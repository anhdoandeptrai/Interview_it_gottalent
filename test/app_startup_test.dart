import 'package:flutter_test/flutter_test.dart';
import 'package:interview_app/main.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Try to pump the app and verify it doesn't crash
    try {
      await tester.pumpWidget(const MyApp());
      // If we get here, the app didn't crash during initialization
      expect(find.byType(MyApp), findsOneWidget);
    } catch (e) {
      // If there's an error, fail the test with the error message
      fail('App crashed during startup: $e');
    }
  });
}
