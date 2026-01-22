<?php
include 'conn.php';

// Menangkap data
$id_schedule = $_POST['id_schedule']; // Kunci utama untuk update
$title       = mysqli_real_escape_string($conn, $_POST['title']);
$description = mysqli_real_escape_string($conn, $_POST['description']);
$datetime    = $_POST['date_time']; // Sesuaikan dengan key di Flutter (date_time)

// Query UPDATE (Bukan Insert)
$query = "UPDATE schedules 
          SET title = '$title', 
              description = '$description', 
              datetime = '$datetime' 
          WHERE id_schedule = '$id_schedule'";

if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success", "message" => "Jadwal berhasil diperbarui"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal update: " . mysqli_error($conn)]);
}
?>