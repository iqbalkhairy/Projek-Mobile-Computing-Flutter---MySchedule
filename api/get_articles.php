<?php
include 'conn.php';

// Gunakan struktur query yang sama dengan get_schedules
// Kita ambil data artikel dan join ke tabel users untuk dapat nama penulisnya
$query = "SELECT articles.*, users.full_name, users.username, users.profile_picture 
          FROM articles 
          LEFT JOIN users ON articles.id_user = users.id_user 
          ORDER BY id_article DESC";

$result = mysqli_query($conn, $query);
$list_artikel = [];

while ($row = mysqli_fetch_assoc($result)) {
    $list_artikel[] = $row;
}

echo json_encode($list_artikel);
?>