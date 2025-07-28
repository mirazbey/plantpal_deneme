// test/widget_test.dart (SON, BASİT VE HATASIZ HALİ)

import 'package:flutter_test/flutter_test.dart';
import 'package:plantpal/main.dart';
import 'package:plantpal/main_screen_shell.dart';

void main() {
  testWidgets('Uygulama ana ekranı smoke test', (WidgetTester tester) async {
    // MyApp widget'ını başlat.
    await tester.pumpWidget(const MyApp());

    // Ekranda MainScreenShell'in olup olmadığını kontrol et.
    expect(find.byType(MainScreenShell), findsOneWidget);
  });
}