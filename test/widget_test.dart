import 'package:app_geolocator/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App arranca con tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('El GPS en Flutter con geolocator'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Leer'), findsWidgets);
    expect(find.text('Seguir'), findsOneWidget);
    expect(find.text('Contratos'), findsOneWidget);
  });
}
