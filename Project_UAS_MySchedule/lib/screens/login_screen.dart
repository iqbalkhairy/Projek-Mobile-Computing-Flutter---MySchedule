import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

// Fitur: Halaman Login User
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller input text
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // State UI
  bool isLoading = false;
  bool _isPasswordVisible = false;

  // Fungsi Login
  void login() async {
    // 1. Validasi Input
    if (userController.text.isEmpty || passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Isi username & password!"),
            backgroundColor: Colors.orange
        ),
      );
      return;
    }

    // 2. Loading UI
    setState(() => isLoading = true);

    try {
      final api = ApiService();
      // 3. Panggil API Login
      final response = await api.login(userController.text, passController.text);

      // Cek mounted (Async Gap)
      if (!mounted) return;

      if (response['status'] == 'success') {
        // --- SUKSES LOGIN ---
        debugPrint("Login Berhasil: ${response['data']}"); // Cek data di debug console

        // 4. Simpan Sesi ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var userData = response['data'];

        if (userData != null) {
          await prefs.setString('id_user', userData['id_user'].toString());
          await prefs.setString('username', userData['username'] ?? "-");
          await prefs.setString('full_name', userData['full_name'] ?? "Pengguna");

          // --- PENTING: MENYIMPAN ROLE ---
          // Ini yang membuat fitur Admin (Hapus postingan orang) bekerja
          await prefs.setString('role', userData['role'] ?? "user");

          // Simpan foto profil jika ada
          String? pic = userData['profile_picture'];
          if (pic != null && pic.isNotEmpty) {
            await prefs.setString('profile_picture', pic);
          } else {
            await prefs.remove('profile_picture');
          }
        }

        // Tandai sudah login
        await prefs.setBool('isLogin', true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Berhasil!"), backgroundColor: Colors.green),
        );

        // 5. Pindah ke Home (Hapus Login dari history navigasi)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

      } else {
        // --- GAGAL ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? "Login Gagal"),
              backgroundColor: Colors.red
          ),
        );
      }
    } catch (e) {
      // --- ERROR ---
      debugPrint("Error Login Screen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
      );
    } finally {
      // 6. Matikan Loading
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text("MySchedule Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Username
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person)
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextField(
                controller: passController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Login
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white
                ),
                child: const Text("LOGIN"),
              ),

              const SizedBox(height: 20),

              // Tombol Daftar
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
                child: const Text("Belum punya akun? Daftar disini"),
              )
            ],
          ),
        ),
      ),
    );
  }
}