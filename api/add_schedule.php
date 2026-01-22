<?php
header('Content-Type: application/json');
include 'conn.php';

// Menangkap data dari Flutter
$user  = isset($_POST['user_id']) ? $_POST['user_id'] : '';
$title = isset($_POST['title']) ? $_POST['title'] : '';
$desc  = isset($_POST['description']) ? $_POST['description'] : '';
$time  = isset($_POST['date_time']) ? $_POST['date_time'] : '';

// Validasi input wajib
if ($user === '' || $title === '') {
    echo json_encode(["status" => "error", "message" => "ID User atau Judul tidak boleh kosong"]);
    exit();
}

// Gunakan mysqli_real_escape_string agar aman dari karakter petik (')
$safe_title = mysqli_real_escape_string($conn, $title);
$safe_desc  = mysqli_real_escape_string($conn, $desc);

// Query sesuai struktur tabel schedules
$sql = "INSERT INTO schedules (id_user, title, description, datetime) 
        VALUES ('$user', '$safe_title', '$safe_desc', '$time')";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Jadwal berhasil disimpan"]);
} else {
    // Menampilkan error database (misal: foreign key fail)
    echo json_encode(["status" => "error", "message" => "Database Error: " . mysqli_error($conn)]);
}