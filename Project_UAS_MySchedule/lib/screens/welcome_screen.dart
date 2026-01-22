import 'package:flutter/material.dart';
import 'login_screen.dart';

// Fitur: Halaman Onboarding (Sambutan)
// Halaman ini hanya muncul jika user belum pernah login sebelumnya.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea: Menjaga UI agar tidak tertutup notch/poni HP atau status bar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. GAMBAR ILUSTRASI
              // Fitur: Menampilkan gambar dari internet.
              // Note: Pastikan HP/Emulator terkoneksi internet agar gambar ini muncul.
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          "https://img.freepik.com/free-vector/time-management-concept-illustration_114360-1013.jpg?w=740"
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. JUDUL APLIKASI
              // Fitur: Branding aplikasi
              const Text(
                "MySchedule",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 15),

              // 3. DESKRIPSI
              // Fitur: Penjelasan singkat fungsi aplikasi kepada user baru
              Text(
                "Atur jadwal kuliah, tugas, dan kegiatan harianmu dengan lebih mudah dan terorganisir.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const Spacer(), // Mendorong tombol ke bagian bawah layar

              // 4. TOMBOL MULAI
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Fitur: Navigasi Satu Arah
                    // pushReplacement digunakan agar user TIDAK BISA kembali ke halaman Welcome
                    // setelah menekan tombol Back di halaman Login.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Mulai Sekarang",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded)
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}