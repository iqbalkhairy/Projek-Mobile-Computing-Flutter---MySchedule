<?php
include 'conn.php';
header('Content-Type: application/json');

$id_article = $_POST['id_article'];
$id_user    = $_POST['id_user']; // ID orang yang mencoba menghapus

// 1. Cek Role User yang sedang login
$cek_user = mysqli_query($conn, "SELECT role FROM users WHERE id_user = '$id_user'");
$user_data = mysqli_fetch_assoc($cek_user);
$role = $user_data['role'] ?? 'user';

// 2. Logic Hapus
if ($role == 'admin') {
    // JIKA ADMIN: Hapus tanpa peduli siapa pemiliknya
    $sql = "DELETE FROM articles WHERE id_article='$id_article'";
} else {
    // JIKA USER BIASA: Hapus HANYA JIKA id_article dan id_user cocok (milik sendiri)
    $sql = "DELETE FROM articles WHERE id_article='$id_article' AND id_user='$id_user'";
}

if (mysqli_query($conn, $sql)) {
    if (mysqli_affected_rows($conn) > 0) {
        echo json_encode(["status" => "success", "message" => "Postingan dihapus"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal hapus (Bukan milik Anda)"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Database Error"]);
}
?>