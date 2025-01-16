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

// Validasi parameter id
$id = isset($data['id']) ? intval($data['id']) : null;

if (empty($id)) {
    echo json_encode(["error" => "Missing parameters"]);
    $conn->close();
    exit;
}

// Query DELETE dengan prepared statement
$stmt = $conn->prepare("DELETE FROM notes WHERE id = ?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["error" => $stmt->error]);
}

// Tutup koneksi
$stmt->close();
$conn->close();
?>
