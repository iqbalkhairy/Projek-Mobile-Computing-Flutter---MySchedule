<?php
// Pastikan tidak ada spasi atau teks apa pun sebelum tag <?php di atas

$host = 'localhost';
$user = 'ujat7577_iqbal';
$pass = 'iqbal2004'; // Password terbaru Anda
$db   = 'ujat7577_db_myschedule';

$conn = mysqli_connect($host, $user, $pass, $db);

if ($conn) {
    echo "<h1>✅ KONEKSI BERHASIL!</h1>";
    echo "User <b>$user</b> sukses terhubung ke database <b>$db</b>";
} else {
    echo "<h1>❌ KONEKSI GAGAL</h1>";
    echo "Penyebab: " . mysqli_connect_error();
}
?>