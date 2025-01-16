<?php
header("Content-Type: application/json");

$host = "localhost";
$user = "root";
$pass = "";
$db = "notes_db";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$sql = "SELECT * FROM notes ORDER BY created_at DESC";
$result = $conn->query($sql);

$notes = [];
while ($row = $result->fetch_assoc()) {
    $notes[] = $row;
}

echo json_encode($notes);
$conn->close();
?>
