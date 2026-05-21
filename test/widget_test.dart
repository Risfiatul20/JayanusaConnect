import 'package:flutter_test/flutter_test.dart';
import 'package:jayanusa_connect/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JayanusaConnectApp());
    expect(find.byType(JayanusaConnectApp), findsOneWidget);
  });
}
