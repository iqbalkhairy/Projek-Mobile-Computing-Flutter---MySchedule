import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // NOTE: Variabel _selectedRole DIHAPUS karena tidak lagi dipilih lewat UI.

  Future<void> handleRegister() async {
    // Validasi input kosong
    if (userController.text.isEmpty || passController.text.isEmpty || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua kolom wajib diisi!")));
      return;
    }

    final api = ApiService();

    // LOGIC UPDATE:
    // Kita tetap mengirim 4 parameter agar sesuai dengan api_service.dart.
    // Tapi parameter ke-4 (role) kita paksa (hardcode) menjadi 'user'.
    // Ini mencegah orang mendaftar sebagai 'admin' secara sembarangan.
    var res = await api.register(
        userController.text,
        nameController.text,
        passController.text,
        'user' // <-- Otomatis jadi 'user'
    );

    if (!mounted) return;

    if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registrasi Berhasil! Silakan Login"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Daftar Akun Baru"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: userController, decoration: const InputDecoration(filled: true, fillColor: Color(0xFFE8F0FE), border: InputBorder.none)),
              const SizedBox(height: 15),

              const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: nameController, decoration: const InputDecoration(filled: true, fillColor: Color(0xFFE8F0FE), border: InputBorder.none)),
              const SizedBox(height: 15),

              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: passController, obscureText: true, decoration: const InputDecoration(filled: true, fillColor: Color(0xFFE8F0FE), border: InputBorder.none)),

              // NOTE: Bagian Dropdown "Daftar Sebagai" sudah dihapus total dari sini.

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleRegister,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AEEF)),
                  child: const Text("DAFTAR SEKARANG", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}