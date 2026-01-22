import 'package:flutter_test/flutter_test.dart';
import 'package:project_uas_myschedule/main.dart'; // Pastikan nama project sesuai
import 'package:project_uas_myschedule/screens/welcome_screen.dart'; // Wajib import ini

void main() {
  testWidgets('App start test', (WidgetTester tester) async {
    // REVISI: Ganti 'startLogin: false' menjadi 'startScreen: const WelcomeScreen()'
    // Ini menyesuaikan dengan perubahan tipe data dari bool ke Widget di MyApp
    await tester.pumpWidget(const MyApp(startScreen: WelcomeScreen()));
  });
}