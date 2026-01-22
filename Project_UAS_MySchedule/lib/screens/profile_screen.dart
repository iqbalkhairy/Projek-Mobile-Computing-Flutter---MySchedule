import 'dart:io'; // Fitur: Akses File (untuk gambar)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Fitur: Simpan/Ambil data sesi user
import 'package:image_picker/image_picker.dart'; // Fitur: Buka Galeri HP
import '../services/api_service.dart'; // Fitur: Koneksi ke API
import 'welcome_screen.dart'; // Fitur: Navigasi saat logout

// Fitur: Halaman Profil User (Melihat & Mengedit Data Diri)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State: Data User yang akan ditampilkan di UI
  String fullName = "Loading...";
  String username = "";
  String? profilePicUrl;

  // State: File gambar baru jika user ingin ganti foto
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fitur: Otomatis load data user saat halaman dibuka pertama kali
    _loadUserData();
  }

  // 1. Fungsi Ambil Data User (Dari Memory HP / SharedPreferences)
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('full_name') ?? "Pengguna";
      username = prefs.getString('username') ?? "-";

      String? picName = prefs.getString('profile_picture');
      if (picName != null && picName.isNotEmpty) {
        // Fitur: Menampilkan foto profil dari server hosting
        profilePicUrl = "https://iqbal.ujangkedu.my.id/api/uploads/$picName";
      }
    });
  }

  // 2. Fungsi Pilih Foto dari Galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Simpan file sementara di variabel state
      });
      // Fitur: Langsung munculkan dialog konfirmasi edit setelah pilih foto
      _showEditDialog();
    }
  }

  // 3. Dialog Edit Profil (Pop-up Form)
  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: fullName);
    TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profil"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fitur: Preview foto baru (jika user baru saja memilih dari galeri)
                if (_imageFile != null)
                  Column(
                    children: [
                      ClipOval(child: Image.file(_imageFile!, width: 80, height: 80, fit: BoxFit.cover)),
                      const SizedBox(height: 10),
                      const Text("Foto Baru Terpilih!", style: TextStyle(color: Colors.green, fontSize: 12)),
                      const SizedBox(height: 10),
                    ],
                  ),

                // Input Nama Lengkap
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nama Lengkap"),
                ),
                // Input Password Baru (Opsional)
                TextField(
                  controller: passController,
                  decoration: const InputDecoration(labelText: "Password Baru (Opsional)", hintText: "Kosongkan jika tidak diganti"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                // Jalankan proses update ke server
                _updateProfile(nameController.text, passController.text);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // 4. Fungsi Kirim Data Update ke Server
  void _updateProfile(String newName, String newPass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUser = prefs.getString('id_user');

    if (idUser != null) {
      final api = ApiService();

      // Cek Mounted: Mencegah error jika user menutup layar saat loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menyimpan...")));

      // PROSES ASYNC: Kirim data ke API update_profile.php
      final response = await api.updateProfile(idUser, newName, newPass, _imageFile);

      // Cek Mounted lagi setelah proses async selesai
      if (!mounted) return;

      if (response['status'] == 'success') {
        // Fitur: Update data di Memory HP agar sinkron dengan Server
        await prefs.setString('full_name', response['data']['full_name']);
        if (response['data']['profile_picture'] != null) {
          await prefs.setString('profile_picture', response['data']['profile_picture']);
        }

        setState(() => _imageFile = null); // Reset foto sementara
        _loadUserData(); // Refresh tampilan UI

        // Cek Mounted lagi sebelum tampilkan pesan sukses
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil diupdate!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    }
  }

  // 5. Fungsi Logout
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Fitur: Hapus semua data sesi user di HP

    if (!mounted) return;
    // Fitur: Redirect ke halaman Welcome dan hapus history navigasi (User tak bisa back ke Profil)
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
  }

  // 6. Dialog Konfirmasi Logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout(); // Panggil fungsi logout di atas
            },
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya"), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bagian Foto Profil (Stack digunakan untuk menumpuk Icon Kamera diatas Foto)
              Stack(
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3),
                      // Logic: Tampilkan gambar server jika ada, jika tidak null
                      image: profilePicUrl != null
                          ? DecorationImage(image: NetworkImage(profilePicUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    // Logic: Jika gambar null, tampilkan icon Orang (Placeholder)
                    child: profilePicUrl == null ? const Icon(Icons.person, size: 80, color: Colors.grey) : null,
                  ),
                  // Tombol Kamera Kecil di Pojok Bawah
                  Positioned(
                    bottom: 0, right: 0,
                    child: InkWell(
                      onTap: _pickImage, // Trigger fungsi ganti foto
                      child: const CircleAvatar(backgroundColor: Colors.blueAccent, radius: 18, child: Icon(Icons.camera_alt, size: 18, color: Colors.white)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Info User (Nama & Username)
              Text("Halo, $fullName!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("@$username", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              // Tombol Aksi (Edit & Logout)
              ElevatedButton.icon(onPressed: _showEditDialog, icon: const Icon(Icons.edit), label: const Text("Edit Profil")),
              const SizedBox(height: 10),
              ElevatedButton.icon(onPressed: _confirmLogout, icon: const Icon(Icons.logout), label: const Text("Keluar"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}