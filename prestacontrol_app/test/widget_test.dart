import 'package:flutter_test/flutter_test.dart';
import 'package:prestacontrol_app/main.dart';

void main() {
  testWidgets('La app arranca y muestra el splash de PrestaControl', (WidgetTester tester) async {
    await tester.pumpWidget(const PrestaControlApp());
    await tester.pump();

    expect(find.text('PrestaControl'), findsOneWidget);
  });
}
