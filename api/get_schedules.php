<?php
include 'conn.php';
$id_user = $_GET['user_id']; // Parameter dari Flutter
// Sesuaikan WHERE id_user (sesuai gambar DB)
$query = "SELECT * FROM schedules WHERE id_user = '$id_user' ORDER BY datetime ASC";
$result = mysqli_query($conn, $query);
$list_jadwal = [];
while ($row = mysqli_fetch_assoc($result)) {
    $list_jadwal[] = $row;
}
echo json_encode($list_jadwal);
?>