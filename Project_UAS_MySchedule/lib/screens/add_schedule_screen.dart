import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

// Fitur: Halaman Tambah ATAU Edit Jadwal (Multifungsi)
class AddScheduleScreen extends StatefulWidget {
  // Jika scheduleData diisi, berarti ini Mode EDIT. Jika null, Mode TAMBAH.
  final Map? scheduleData;

  const AddScheduleScreen({super.key, this.scheduleData});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  // Controller khusus untuk menampilkan teks tanggal/jam di UI (User Friendly)
  TextEditingController dateDisplayController = TextEditingController();
  TextEditingController timeDisplayController = TextEditingController();

  // Variabel Logika: Menyimpan nilai asli (Object) untuk diproses
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Flag penanda apakah ini mode edit atau tambah
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Cek apakah ada data kiriman dari halaman sebelumnya
    if (widget.scheduleData != null) {
      isEditMode = true; // Aktifkan mode edit
      titleController.text = widget.scheduleData!['title'];
      descController.text = widget.scheduleData!['description'];

      // PARSING DATA DARI DATABASE (String MySQL -> DateTime Dart)
      try {
        // Format dari DB: "2026-01-20 08:30:00"
        DateTime dt = DateTime.parse(widget.scheduleData!['datetime']);

        // Simpan ke variabel logika
        selectedDate = dt;
        selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);

        // Tampilkan di UI TextField
        dateDisplayController.text = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
        timeDisplayController.text = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }
  }

  // 1. FUNGSI MEMILIH TANGGAL (DatePicker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(), // Default hari ini
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Format tampilan ke YYYY-MM-DD
        dateDisplayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // 2. FUNGSI MEMILIH JAM (TimePicker)
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          // Paksa format 24 jam (opsional, tergantung selera)
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        // Format tampilan jam:menit AM/PM otomatis dari Flutter
        timeDisplayController.text = picked.format(context);
      });
    }
  }

  // 3. FUNGSI SIMPAN/UPDATE KE SERVER
  void submit() async {
    // Validasi Input: Pastikan semua terisi
    if (titleController.text.isEmpty || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi Judul, Tanggal, dan Jam"), backgroundColor: Colors.orange),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // FIX: Tambahkan ini untuk menghilangkan warning "Async Gap"
    if (!mounted) return;

    String? idUser = prefs.getString('id_user');
    final api = ApiService();

    // Debugging Console (Gunakan debugPrint agar aman)
    debugPrint("DEBUG: ID User = $idUser");
    debugPrint("DEBUG: Judul = ${titleController.text}");

    // Format Tanggal & Jam untuk MySQL (YYYY-MM-DD HH:MM:SS)
    String finalDateTime =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} "
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

    if (idUser != null) {
      Map<String, dynamic> response;

      // Fitur UI: Munculkan Loading Spinner
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator())
      );

      try {
        // Cek Mode: Edit atau Tambah Baru?
        if (isEditMode) {
          response = await api.updateSchedule(
            widget.scheduleData!['id_schedule'].toString(),
            titleController.text,
            descController.text,
            finalDateTime,
          );
        } else {
          response = await api.addSchedule(
            idUser,
            titleController.text,
            descController.text,
            finalDateTime,
          );
        }

        // FIX: Cek mounted sebelum menutup dialog loading
        if (!mounted) return;
        Navigator.pop(context); // Tutup Loading Spinner

        // Cek Respon Server
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
          Navigator.pop(context); // Tutup Halaman (Kembali ke Home)
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? "Gagal menyimpan data"),
                backgroundColor: Colors.red,
              )
          );
        }
      } catch (e) {
        // Handle Crash / Error Koneksi Internet
        if (!mounted) return;
        Navigator.pop(context); // Pastikan loading tertutup meski error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kesalahan Jaringan: $e"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Sesi berakhir. Silakan Logout dan Login kembali."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul Dinamis: Berubah sesuai mode
        title: Text(isEditMode ? "Edit Jadwal" : "Tambah Jadwal"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input Judul
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul Kegiatan",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 15),

            // Input Deskripsi (Bisa Multiline)
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            // Baris Input Tanggal & Jam (Side by Side)
            Row(
              children: [
                Expanded(
                  // ReadOnly agar keyboard tidak muncul (hanya bisa diklik)
                  child: TextField(
                    controller: dateDisplayController,
                    readOnly: true,
                    onTap: () => _selectDate(context), // Panggil DatePicker
                    decoration: const InputDecoration(
                      labelText: "Pilih Tanggal",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: timeDisplayController,
                    readOnly: true,
                    onTap: () => _selectTime(context), // Panggil TimePicker
                    decoration: const InputDecoration(
                      labelText: "Pilih Jam",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Tombol Simpan
            ElevatedButton(
              onPressed: submit, // Panggil fungsi submit
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditMode ? "UPDATE DATA" : "SIMPAN DATA"),
            )
          ],
        ),
      ),
    );
  }
}