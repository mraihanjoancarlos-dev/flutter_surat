<?php
// ============================================================
// config.php — Konfigurasi Database + Helper
// Letakkan folder /api/ di server yang sama dengan web SIMFARS
// ============================================================

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'db_surat');

// ⚠ Ganti dengan secret key yang kuat
define('JWT_SECRET', 'simfars_secret_key_2024');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

function getDB() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        resp("error", "Koneksi database gagal: " . $conn->connect_error, null, 500);
    }
    $conn->set_charset("utf8");
    return $conn;
}

function resp($status, $message, $data = null, $code = 200) {
    http_response_code($code);
    $r = ["status" => $status, "message" => $message];
    if ($data !== null) $r["data"] = $data;
    echo json_encode($r, JSON_UNESCAPED_UNICODE);
    exit();
}

// Simple JWT-like token pakai base64 (tanpa library tambahan)
function generateToken($adminId, $username) {
    $payload = base64_encode(json_encode([
        "id"       => $adminId,
        "username" => $username,
        "exp"      => time() + (60 * 60 * 24) // 24 jam
    ]));
    $sig = hash_hmac('sha256', $payload, JWT_SECRET);
    return $payload . '.' . $sig;
}

function verifyToken($token) {
    if (empty($token)) return false;
    $parts = explode('.', $token);
    if (count($parts) !== 2) return false;
    [$payload, $sig] = $parts;
    $expected = hash_hmac('sha256', $payload, JWT_SECRET);
    if (!hash_equals($expected, $sig)) return false;
    $data = json_decode(base64_decode($payload), true);
    if (!$data || $data['exp'] < time()) return false;
    return $data;
}

function getAuthToken() {
    $headers = getallheaders();
    $auth = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    if (str_starts_with($auth, 'Bearer ')) {
        return substr($auth, 7);
    }
    return '';
}

function requireAuth() {
    $token = getAuthToken();
    $data  = verifyToken($token);
    if (!$data) {
        resp("error", "Unauthorized - token tidak valid atau expired", null, 401);
    }
    return $data;
}
