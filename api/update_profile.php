<?php
// MATIKAN SEMUA ERROR DISPLAY AGAR JSON TIDAK RUSAK
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
include 'conn.php';

// 1. Cek Koneksi Database Dulu
if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Koneksi Database Gagal"]);
    exit();
}

// 2. Tangkap Data
$id_user   = isset($_POST['id_user']) ? $_POST['id_user'] : '';
$full_name = isset($_POST['full_name']) ? $_POST['full_name'] : '';
$password  = isset($_POST['password']) ? $_POST['password'] : '';

if (empty($id_user)) {
    echo json_encode(["status" => "error", "message" => "ID User tidak ditemukan"]);
    exit();
}

// 3. Siapkan Query Update Nama
$sql = "UPDATE users SET full_name = '$full_name' ";

// 4. Cek Password (Update jika diisi)
if (!empty($password)) {
    // Jika password di database plain text, gunakan baris pertama. 
    // Jika pakai hash, gunakan baris kedua (pilih salah satu sesuai sistem register Anda).
    
    // Opsi A (Plain Text):
    // $sql .= ", password = '$password' "; 
    
    // Opsi B (Hash - Disarankan):
    $password_hash = password_hash($password, PASSWORD_DEFAULT);
    $sql .= ", password = '$password_hash' "; 
}

// 5. Cek Upload Foto
if (isset($_FILES['image']['name']) && $_FILES['image']['name'] != "") {
    $target_dir = "uploads/";
    
    // Buat folder jika belum ada (Backup logic)
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }

    $fileName       = basename($_FILES['image']['name']);
    $fileType       = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
    $allowTypes     = array('jpg', 'png', 'jpeg', 'gif');
    
    // Validasi Tipe File
    if(in_array($fileType, $allowTypes)){
        // Nama file unik: profile_ID_WAKTU.jpg
        $newFileName = "profile_" . $id_user . "_" . time() . "." . $fileType;
        $targetFilePath = $target_dir . $newFileName;
        
        if (move_uploaded_file($_FILES['image']['tmp_name'], $targetFilePath)) {
            $sql .= ", profile_picture = '$newFileName' ";
        } else {
            // Jika gagal upload, kirim JSON error (jangan biarkan PHP muntah error warning)
            echo json_encode(["status" => "error", "message" => "Gagal memindahkan file gambar. Cek folder uploads."]);
            exit();
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Format file harus JPG, JPEG, PNG, atau GIF"]);
        exit();
    }
}

// 6. Eksekusi Query
$sql .= " WHERE id_user = '$id_user'";

if (mysqli_query($conn, $sql)) {
    // Ambil data terbaru untuk dikembalikan ke Flutter
    $query = mysqli_query($conn, "SELECT * FROM users WHERE id_user = '$id_user'");
    $row   = mysqli_fetch_assoc($query);
    
    echo json_encode([
        "status" => "success", 
        "message" => "Profil berhasil diperbarui",
        "data" => $row
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Database Error: " . mysqli_error($conn)]);
}
?>