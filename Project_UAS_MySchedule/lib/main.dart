import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

// FIX: Entry point aplikasi
void main() async {
  // 1. Inisialisasi binding (Wajib untuk SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cek Sesi Login
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.containsKey('id_user');

  // 3. Tentukan Halaman Awal
  Widget halamanPertama = isLoggedIn ? const HomeScreen() : const WelcomeScreen();

  // FIX: Gunakan debugPrint agar tidak muncul warning "Don't invoke print in production"
  debugPrint("==== STATUS LOGIN SAAT INI: $isLoggedIn ====");

  runApp(MyApp(startScreen: halamanPertama));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MySchedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}