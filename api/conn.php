<?php
$host = 'localhost';
$user = 'ujat7577_iqbal';
$pass = 'iqbal2004';
$db   = 'ujat7577_db_myschedule';

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
    header('Content-Type: application/json');
    die(json_encode(["status" => "error", "message" => "Database disconnect"]));
}
?>