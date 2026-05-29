import 'package:flutter_test/flutter_test.dart';
import 'package:admin_web/main.dart';

void main() {

  testWidgets(
    'SensorIA Admin carga correctamente',
    (WidgetTester tester) async {

      await tester.pumpWidget(
        const SensorIAAdmin(),
      );

      expect(
        find.text('Dashboard'),
        findsOneWidget,
      );
    },
  );
}