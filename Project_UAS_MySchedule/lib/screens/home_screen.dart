import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'article_screen.dart';
import 'add_schedule_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State: Menyimpan daftar jadwal dari database
  List scheduleList = [];
  // State: Loading indicator saat data sedang diambil
  bool isLoading = true;
  // State: Menyimpan nama user untuk ditampilkan di AppBar
  String fullName = "";

  @override
  void initState() {
    super.initState();
    // Fitur: Otomatis ambil data saat halaman pertama kali dibuka
    getUserName(); // <--- Ambil Nama User
    getSchedules(); // <--- Ambil Jadwal
  }

  // 1. Fungsi Ambil Nama User (Untuk Judul AppBar)
  Future<void> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ambil 'full_name', jika kosong ambil 'username', jika kosong tulis 'Pengguna'
      fullName = prefs.getString('full_name') ?? prefs.getString('username') ?? "Pengguna";
    });
  }

  // 2. Fungsi Ambil Data Jadwal (Read)
  Future<void> getSchedules() async {
    // Ambil ID User yang sedang login dari memori HP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUser = prefs.getString('id_user');

    if (idUser != null) {
      final api = ApiService();
      // Panggil API get_schedules.php
      List<dynamic> result = await api.getSchedules(idUser);

      if (!mounted) return;
      // Update UI dengan data baru
      setState(() {
        scheduleList = result;
        isLoading = false; // Matikan loading
      });
    }
  }

  // 3. Fungsi Hapus Data (Delete)
  void deleteData(String idSchedule) async {
    final api = ApiService();
    // Panggil API delete_schedule.php
    var response = await api.deleteSchedule(idSchedule);

    if (!mounted) return;

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
      // Fitur: Refresh data otomatis setelah menghapus agar list terupdate
      getSchedules();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ---
      appBar: AppBar(
        // REVISI: Judul diganti menjadi Sapaan User
        // Menggunakan Column agar teks "Halo" dan "Nama" tersusun rapi atas-bawah
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
          children: [
            const Text(
                "Halo, Selamat Datang",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)
            ),
            Text(
                fullName, // Nama dinamis dari Shared Preferences
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Navigasi ke Artikel (Social Feed)
          IconButton(
            icon: const Icon(Icons.article),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleScreen()));
            },
          ),

          // Tombol Navigasi ke Profil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              // 'await' digunakan agar saat kembali dari profil, data jadwal di-refresh (misal nama user berubah)
              await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              // Refresh nama dan jadwal setelah kembali dari edit profil
              getUserName();
              getSchedules();
            },
          )
        ],
      ),

      // --- BODY (DAFTAR JADWAL) ---
      // RefreshIndicator: Fitur tarik ke bawah untuk refresh (Pull-to-Refresh)
      body: RefreshIndicator(
        onRefresh: () async {
          await getUserName(); // Refresh nama juga
          await getSchedules();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Tampilkan loading jika data belum siap
            : scheduleList.isEmpty
            ? const Center(child: Text("Belum ada jadwal. Tekan + untuk buat.")) // Tampilkan jika kosong
            : ListView.builder( // Render list secara efisien
          itemCount: scheduleList.length,
          itemBuilder: (context, index) {
            final item = scheduleList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 3,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.calendar_today, color: Colors.white),
                ),
                // Judul Jadwal
                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                // Deskripsi & Tanggal
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['description'] ?? "-"),
                    const SizedBox(height: 5),
                    Text(item['datetime'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                // --- TOMBOL AKSI (EDIT & DELETE) ---
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () async {
                        // Navigasi ke AddScheduleScreen dengan membawa data (Mode Edit)
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddScheduleScreen(scheduleData: item),
                          ),
                        );
                        // Refresh setelah edit selesai
                        getSchedules();
                      },
                    ),
                    // Tombol Delete
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Tampilkan Pop-up Konfirmasi
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Hapus Jadwal?"),
                            content: const Text("Apakah anda yakin untuk menghapus jadwal nya?"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Batal")
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx); // Tutup Dialog
                                  deleteData(item['id_schedule']); // Jalankan fungsi hapus
                                },
                                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // --- TOMBOL TAMBAH (+) ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          // Navigasi ke AddScheduleScreen tanpa data (Mode Buat Baru)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddScheduleScreen()),
          );
          // Refresh data setelah tambah jadwal
          getSchedules();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}