<?php
include 'conn.php';
header('Content-Type: application/json');

$username = $_POST['username'];
$password = $_POST['password'];

// 1. Ambil data user berdasarkan username
$sql = "SELECT id_user, username, full_name, password, role, profile_picture FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $sql);

if ($result && mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    
    // 2. VERIFIKASI PASSWORD (PENTING!)
    // password_verify akan mengecek apakah 'iqbal2004' cocok dengan hash '$2y$10$...'
    if (password_verify($password, $row['password'])) {
        
        echo json_encode([
            "status" => "success",
            "message" => "Login Berhasil",
            "data" => [
                "id_user" => $row['id_user'],
                "username" => $row['username'],
                "full_name" => $row['full_name'],
                "role" => $row['role'],
                "profile_picture" => $row['profile_picture']
            ]
        ]);
        
    } else {
        // Jika password_verify gagal, kita coba cek manual (jaga-jaga kalau ada password lama yang belum di-hash/masih plain text)
        if ($password == $row['password']) {
             echo json_encode([
                "status" => "success",
                "message" => "Login Berhasil (Legacy)",
                "data" => [
                    "id_user" => $row['id_user'],
                    "username" => $row['username'],
                    "full_name" => $row['full_name'],
                    "role" => $row['role'],
                    "profile_picture" => $row['profile_picture']
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Password Salah"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Username tidak ditemukan"]);
}
?>