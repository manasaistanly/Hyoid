// Basic smoke test for Hyoid App.
import 'package:flutter_test/flutter_test.dart';
import 'package:hyoid_app/main.dart';

void main() {
  testWidgets('Hyoid app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const HyoidApp());
    expect(find.text('HYOID'), findsOneWidget);
  });
}
