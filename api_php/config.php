<?php
// ============================================================
// config.php — Konfigurasi Database MySQL
// Letakkan file ini di server yang sama dengan web sistem informasi
// ============================================================

define('DB_HOST', 'localhost');
define('DB_USER', 'root');          // ganti dengan user MySQL kamu
define('DB_PASS', '');              // ganti dengan password MySQL kamu
define('DB_NAME', 'db_surat');      // ganti dengan nama database kamu

// Header CORS agar Flutter bisa akses API
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

function getConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Koneksi database gagal: " . $conn->connect_error]);
        exit();
    }
    $conn->set_charset("utf8");
    return $conn;
}

function response($status, $message, $data = null) {
    $result = ["status" => $status, "message" => $message];
    if ($data !== null) $result["data"] = $data;
    echo json_encode($result, JSON_UNESCAPED_UNICODE);
    exit();
}
?>
