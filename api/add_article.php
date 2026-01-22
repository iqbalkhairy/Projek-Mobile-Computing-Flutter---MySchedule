<?php
include 'conn.php';
header('Content-Type: application/json');

$id_user = $_POST['id_user'];
$title   = $_POST['title'];
$content = $_POST['content'];

// Default image kosong
$image_url = "";

// Cek apakah ada file gambar yang dikirim?
if (isset($_FILES['image']['name'])) {
    $target_dir = "uploads/";
    // Buat nama file unik: article_IDUSER_TIMESTAMP.jpg
    $image_name = "article_" . $id_user . "_" . time() . ".jpg";
    $target_file = $target_dir . $image_name;

    if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
        $image_url = $image_name; // Simpan nama filenya saja
    }
}

if (!$id_user || !$title || !$content) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit;
}

$sql = "INSERT INTO articles (id_user, title, content, image_url) VALUES ('$id_user', '$title', '$content', '$image_url')";

if (mysqli_query($conn, $sql)) {
    echo json_encode(["status" => "success", "message" => "Berhasil diposting!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal: " . mysqli_error($conn)]);
}
?>