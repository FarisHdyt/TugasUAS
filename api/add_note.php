<?php
header("Content-Type: application/json");

// Konfigurasi database
$host = "localhost";
$user = "root";
$pass = "";
$db = "notes_db";

// Koneksi ke database
$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Ambil data dari body request
$input = file_get_contents("php://input");
$data = json_decode($input, true);

// Validasi data dari body request
$title = isset($data['title']) ? $data['title'] : null;
$content = isset($data['content']) ? $data['content'] : null;

if (empty($title) || empty($content)) {
    echo json_encode(["error" => "Title or content is missing"]);
    $conn->close();
    exit;
}

// Gunakan prepared statement untuk menghindari SQL Injection
$stmt = $conn->prepare("INSERT INTO notes (title, content) VALUES (?, ?)");
$stmt->bind_param("ss", $title, $content);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
?>
