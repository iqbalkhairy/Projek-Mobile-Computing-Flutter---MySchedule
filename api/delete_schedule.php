<?php
include 'conn.php';
$id_schedule = $_POST['id_schedule'];
$query = "DELETE FROM schedules WHERE id_schedule = '$id_schedule'";
if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success", "message" => "Jadwal dihapus"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal hapus"]);
}
?>