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

// Validasi parameter
$id = isset($data['id']) ? intval($data['id']) : null;
$title = isset($data['title']) ? $data['title'] : null;
$content = isset($data['content']) ? $data['content'] : null;

if (empty($id) || empty($title) || empty($content)) {
    echo json_encode(["error" => "Missing parameters"]);
    $conn->close();
    exit;
}

// Update data menggunakan prepared statement
$stmt = $conn->prepare("UPDATE notes SET title = ?, content = ? WHERE id = ?");
$stmt->bind_param("ssi", $title, $content, $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
?>
