import 'dart:convert'; // Fitur: Decode/Encode JSON
import 'dart:io'; // Fitur: Akses File (Gambar)
import 'package:flutter/foundation.dart'; // Fitur: debugPrint (Pengganti print biasa)
import 'package:http/http.dart' as http; // Fitur: Koneksi Server

class ApiService {
  // --- KONFIGURASI SERVER ---
  static const String baseUrl = "https://iqbal.ujangkedu.my.id/api";

  // --- HELPER: Handle Respon ---
  dynamic _handleResponse(http.Response response) {
    // REVISI: Menggunakan debugPrint agar tidak muncul warning kuning
    debugPrint("URL REQUEST: ${response.request?.url}");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("BODY SERVER: ${response.body}");

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) {
          return {"status": "error", "message": "Respon server kosong"};
        }
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint("ERROR DECODE JSON: ${response.body}");
        return {
          "status": "error",
          "message": "Format Data Salah (Bukan JSON). Server mungkin mengirim HTML Error."
        };
      }
    } else {
      return {
        "status": "error",
        "message": "Server Error: ${response.statusCode}"
      };
    }
  }

  // 1. LOGIN
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {"username": username, "password": password},
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      debugPrint("ERROR LOGIN: $e");
      return {"status": "error", "message": "Koneksi Gagal: $e"};
    }
  }

  // 2. REGISTER
  // Note: Sudah ada parameter 'role' sesuai request sebelumnya
  Future<Map<String, dynamic>> register(String username, String fullName, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {
          "username": username,
          "full_name": fullName,
          "password": password,
          "role": role
        },
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      debugPrint("ERROR REGISTER: $e");
      return {"status": "error", "message": "Koneksi Gagal: $e"};
    }
  }

  // 3. GET SCHEDULES
  Future<List<dynamic>> getSchedules(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_schedules.php?user_id=$userId"),
      ).timeout(const Duration(seconds: 10));

      debugPrint("GET SCHEDULES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      debugPrint("Error Get Schedule: $e");
      return [];
    }
  }

  // 4. ADD SCHEDULE
  Future<Map<String, dynamic>> addSchedule(String userId, String title, String desc, String datetime) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_schedule.php"),
        body: {"user_id": userId, "title": title, "description": desc, "date_time": datetime},
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "$e"};
    }
  }

  // 5. UPDATE SCHEDULE
  Future<Map<String, dynamic>> updateSchedule(String id, String title, String desc, String datetime) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_schedule.php"),
        body: {"id_schedule": id, "title": title, "description": desc, "date_time": datetime},
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "$e"};
    }
  }

  // 6. DELETE SCHEDULE
  Future<Map<String, dynamic>> deleteSchedule(String id) async {
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/delete_schedule.php"),
          body: {"id_schedule": id}
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "$e"};
    }
  }

  // 7. UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile(String idUser, String fullName, String password, File? imageFile) async {
    debugPrint("Mencoba Update Profil ke: $baseUrl/update_profile.php");
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/update_profile.php"));

      request.fields['id_user'] = idUser;
      request.fields['full_name'] = fullName;
      if (password.isNotEmpty) {
        request.fields['password'] = password;
      }

      if (imageFile != null) {
        debugPrint("Mengupload file: ${imageFile.path}");
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30)); // Timeout 30s
      var response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint("ERROR UPLOAD: $e");
      return {"status": "error", "message": "Gagal Upload: $e"};
    }
  }

  // --- FITUR ARTIKEL ---

  // 8. GET ARTICLES
  Future<List<dynamic>> getArticles() async {
    try {
      debugPrint("Request Artikel ke: $baseUrl/get_articles.php");
      final response = await http.get(Uri.parse("$baseUrl/get_articles.php"))
          .timeout(const Duration(seconds: 10));

      debugPrint("GET ARTICLES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      debugPrint("Error Get Articles: $e");
      return [];
    }
  }

  // 9. ADD ARTICLE
  Future<Map<String, dynamic>> addArticle(String idUser, String title, String content, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/add_article.php"));

      request.fields['id_user'] = idUser;
      request.fields['title'] = title;
      request.fields['content'] = content;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "$e"};
    }
  }

  // 10. UPDATE ARTICLE
  Future<Map<String, dynamic>> updateArticle(String idArticle, String idUser, String title, String content, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/update_article.php"));

      request.fields['id_article'] = idArticle;
      request.fields['id_user'] = idUser;
      request.fields['title'] = title;
      request.fields['content'] = content;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "$e"};
    }
  }

  // 11. DELETE ARTICLE
  Future<Map<String, dynamic>> deleteArticle(String idArticle, String idUser) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete_article.php"),
        body: {
          "id_article": idArticle,
          "id_user": idUser
        },
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "message": "$e"};
    }
  }
}