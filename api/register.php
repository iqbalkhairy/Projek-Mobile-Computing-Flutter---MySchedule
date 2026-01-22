<?php
header('Content-Type: application/json');
include 'conn.php';

$username  = $_POST['username'];
$full_name = $_POST['full_name'];
$password  = $_POST['password'];

// Cek data kosong
if(empty($username) || empty($password)){
    echo json_encode(["status" => "error", "message" => "Username/Password kosong"]);
    exit();
}

// Cek apakah username sudah ada?
$cek = mysqli_query($conn, "SELECT username FROM users WHERE username = '$username'");
if(mysqli_num_rows($cek) > 0){
    echo json_encode(["status" => "error", "message" => "Username sudah dipakai"]);
    exit();
}

// Enkripsi Password
$password_hash = password_hash($password, PASSWORD_DEFAULT);

// Insert Data (Biarkan id_user AUTO_INCREMENT dari database)
$query = "INSERT INTO users (username, password, full_name) VALUES ('$username', '$password_hash', '$full_name')";

if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success", "message" => "Registrasi Berhasil"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal: " . mysqli_error($conn)]);
}
?>