<?php
include 'conn.php';
header('Content-Type: application/json');

$id_article = $_POST['id_article'];
$id_user    = $_POST['id_user'];
$title      = $_POST['title'];
$content    = $_POST['content'];

if (!$id_article || !$id_user) {
    echo json_encode(["status" => "error", "message" => "ID Data Kosong"]);
    exit;
}

// LOGIKA UPDATE GAMBAR
$image_query = ""; // String tambahan untuk query SQL

if (isset($_FILES['image']['name']) && $_FILES['image']['name'] != "") {
    $target_dir = "uploads/";
    $image_name = "article_" . $id_user . "_" . time() . ".jpg";
    $target_file = $target_dir . $image_name;

    if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
        // Jika upload sukses, kita update kolom image_url juga
        $image_query = ", image_url='$image_name'";
    }
}

// UPDATE DATA (Pastikan hanya pemilik yang bisa update)
$sql = "UPDATE articles SET title='$title', content='$content' $image_query WHERE id_article='$id_article' AND id_user='$id_user'";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Postingan berhasil diupdate!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal Update: " . mysqli_error($conn)]);
}
?>