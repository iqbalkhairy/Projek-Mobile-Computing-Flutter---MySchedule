import 'dart:io'; // Fitur: Untuk menangani File Gambar (Upload)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Fitur: Untuk ambil ID User & Role dari memori HP
import 'package:image_picker/image_picker.dart'; // Fitur: Untuk ambil foto dari Galeri
import '../services/api_service.dart'; // Fitur: Koneksi ke Server (API)

// --- WIDGET KHUSUS: EXPANDABLE TEXT ---
// Fitur: Widget custom untuk menyingkat teks panjang (>50 karakter) dengan tombol "Baca Selengkapnya"
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  // State: Apakah teks sedang dibuka penuh (true) atau disingkat (false)
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Logic: Jika teks pendek (<= 50 karakter), tampilkan biasa saja tanpa tombol
    if (widget.text.length <= 50) {
      return Text(widget.text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5));
    }

    // Logic: Jika teks panjang, tampilkan sebagian + tombol interaktif
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded ? widget.text : "${widget.text.substring(0, 50)}...", // Potong teks jika belum expand
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded), // Ubah status expand saat diklik
          child: Text(
            isExpanded ? "Tampilkan Sedikit" : "Baca Selengkapnya",
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// --- SCREEN UTAMA ARTIKEL (SOCIAL FEED) ---
class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  // State: Menyimpan daftar artikel yang diambil dari server
  List articles = [];
  bool isLoading = true; // Indikator loading saat ambil data

  // State: Data User yang sedang login (Penting untuk validasi hak akses)
  String? currentUserId;
  String? userRole; // Variabel role (admin/user) untuk logika Admin

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fitur: Otomatis load data user dan artikel saat halaman dibuka
    _checkUserAndLoadData();
  }

  // 1. Fungsi Cek User & Role (Authentication Check)
  void _checkUserAndLoadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('id_user');
      userRole = prefs.getString('role'); // Ambil role (admin/user) dari memory HP
    });
    loadArticles(showLoading: true);
  }

  // 2. Fungsi Ambil Data Artikel (Read Data)
  void loadArticles({bool showLoading = false}) async {
    if (showLoading) setState(() => isLoading = true);
    final api = ApiService();
    var data = await api.getArticles(); // Request ke API get_articles.php

    // Validasi Mounted: Mencegah error jika user pindah layar saat loading
    if (!mounted) return;
    setState(() {
      articles = data; // Simpan data ke list untuk ditampilkan
      isLoading = false;
    });
  }

  // 3. Fungsi Hapus Artikel (Delete Data)
  void _deleteArticle(String idArticle) async {
    if (currentUserId == null) return;
    final api = ApiService();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menghapus...")));

    // Kirim request hapus ke server
    final response = await api.deleteArticle(idArticle, currentUserId!);

    if (!mounted) return;
    if (response['status'] == 'success') {
      loadArticles(showLoading: false); // Refresh list tanpa loading screen penuh
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Postingan berhasil dihapus!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
    }
  }

  // --- 4. DIALOG TAMBAH POSTINGAN (Create Data) ---
  void _showAddPostDialog() {
    TextEditingController titleCtrl = TextEditingController();
    TextEditingController contentCtrl = TextEditingController();
    File? selectedImage; // Variabel sementara untuk foto yang dipilih

    showDialog(
      context: context,
      builder: (ctx) { // 'ctx' adalah context milik Dialog
        // Note: StatefulBuilder digunakan agar tampilan DALAM Dialog bisa berubah (misal saat foto dipilih)
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Buat Status Baru"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Area Pilih Gambar (GestureDetector)
                    GestureDetector(
                      onTap: () async {
                        final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          // Update tampilan dialog dengan gambar baru
                          setDialogState(() => selectedImage = File(picked.path));
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        // Logic Tampilan: Jika ada gambar -> Tampilkan Gambar, Jika tidak -> Icon Kamera
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), Text("Tambah Foto", style: TextStyle(color: Colors.grey))]),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Input Judul & Isi
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Isi", border: OutlineInputBorder())),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty && currentUserId != null) {
                      Navigator.pop(ctx); // Tutup dialog

                      // Note: Gunakan 'context' (milik ArticleScreen), BUKAN 'dialogContext' untuk SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sedang mengunggah...")));

                      final api = ApiService();
                      // Kirim Data + Gambar ke API
                      final response = await api.addArticle(currentUserId!, titleCtrl.text, contentCtrl.text, selectedImage);

                      if (!mounted) return; // Cek mounted milik ArticleScreenState

                      if (response['status'] == 'success') {
                        loadArticles(showLoading: false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Postingan berhasil diunggah!"), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}"), backgroundColor: Colors.red));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul dan Isi wajib diisi!")));
                    }
                  },
                  child: const Text("Posting"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // --- 5. DIALOG EDIT POSTINGAN (Update Data) ---
  void _showEditPostDialog(Map item) {
    // Isi controller dengan data lama (Pre-fill)
    TextEditingController titleCtrl = TextEditingController(text: item['title']);
    TextEditingController contentCtrl = TextEditingController(text: item['content']);
    File? selectedImage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Postingan"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Area Gambar (Bisa ganti gambar)
                    GestureDetector(
                      onTap: () async {
                        final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() => selectedImage = File(picked.path));
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        // Prioritas Tampilan: Gambar Baru > Gambar Lama (Server) > Icon Kosong
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : (item['image_url'] != null && item['image_url'] != "")
                            ? Image.network("https://iqbal.ujangkedu.my.id/api/uploads/${item['image_url']}", fit: BoxFit.cover, errorBuilder: (ctx,e,s) => const Icon(Icons.broken_image))
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), Text("Ganti Foto", style: TextStyle(color: Colors.grey))]),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Isi", border: OutlineInputBorder())),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty && currentUserId != null) {
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menyimpan perubahan...")));

                      final api = ApiService();
                      // Panggil API Update
                      final response = await api.updateArticle(item['id_article'].toString(), currentUserId!, titleCtrl.text, contentCtrl.text, selectedImage);

                      if (!mounted) return;

                      if (response['status'] == 'success') {
                        loadArticles(showLoading: false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil diedit!")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                      }
                    }
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Productivity Hub"), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      // Logic Body: Jika loading tampilkan spinner, jika kosong tampilkan pesan, jika ada data tampilkan List
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 10),
            const Text("Belum ada postingan."),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _showAddPostDialog, child: const Text("Mulai Diskusi!"))
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final item = articles[index];

          // --- LOGIKA PERIZINAN (PERMISSION LOGIC) ---

          // 1. Cek Apakah user ini pemilik postingan?
          bool isOwner = item['id_user'].toString() == currentUserId;

          // 2. Cek Apakah user ini Admin?
          bool isAdmin = userRole == 'admin';

          // --- ATURAN MAIN ADMIN vs USER ---

          // EDIT: Hanya boleh Pemilik Asli.
          // (Walaupun Admin, dia TIDAK BOLEH edit tulisan orang lain agar tidak memanipulasi konten)
          bool canEdit = isOwner;

          // HAPUS: Boleh Pemilik ATAU Admin.
          // (Admin boleh hapus postingan siapa saja untuk moderasi konten buruk)
          bool canDelete = isOwner || isAdmin;

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER ARTIKEL (Foto Profil & Nama User)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    // Tampilkan foto profil user penulis artikel
                    backgroundImage: (item['profile_picture'] != null && item['profile_picture'] != "")
                        ? NetworkImage("https://iqbal.ujangkedu.my.id/api/uploads/${item['profile_picture']}")
                        : null,
                    child: (item['profile_picture'] == null || item['profile_picture'] == "")
                        ? const Icon(Icons.person, color: Colors.blue)
                        : null,
                  ),
                  title: Text(item['full_name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("@${item['username']}"),

                  // TOMBOL AKSI (Hanya muncul jika punya izin canEdit atau canDelete)
                  trailing: (canEdit || canDelete)
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit (Hanya muncul jika isOwner = true)
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showEditPostDialog(item),
                        ),

                      // Tombol Delete (Muncul jika isOwner = true ATAU isAdmin = true)
                      if (canDelete)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            // Pop-up Konfirmasi Hapus
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Hapus Postingan?"),
                                // Logic Pesan: Jika Admin hapus punya orang, pesannya beda biar sadar.
                                content: Text(isAdmin && !isOwner
                                    ? "Admin: Anda akan menghapus postingan milik @${item['username']}."
                                    : "Apakah anda yakin ingin menghapus postingan ini?"),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Batal")
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _deleteArticle(item['id_article'].toString()); // Hapus
                                    },
                                    child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  )
                      : null,
                ),

                // GAMBAR ARTIKEL (Hanya tampil jika ada URL gambar)
                if (item['image_url'] != null && item['image_url'] != "")
                  ClipRRect(
                    child: Image.network(
                      "https://iqbal.ujangkedu.my.id/api/uploads/${item['image_url']}",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => Container(height: 50, color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image))),
                    ),
                  ),

                // KONTEN ARTIKEL (Judul & Isi)
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Menggunakan Widget khusus agar teks panjang tidak memenuhi layar
                      ExpandableText(text: item['content'] ?? ""),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Tombol Floating (+) untuk tambah postingan baru
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}