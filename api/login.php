<?php
// ============================================================
// login.php — POST /api/login.php
// Body JSON: { "username": "admin", "password": "password" }
// ============================================================

require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    resp("error", "Method tidak diizinkan", null, 405);
}

$input = json_decode(file_get_contents("php://input"), true);

$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? '');

if (!$username || !$password) {
    resp("error", "Username dan password wajib diisi", null, 400);
}

$conn = getDB();

$stmt = $conn->prepare("SELECT id, nama, username, password, email FROM admin WHERE username = ? LIMIT 1");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    resp("error", "Username tidak ditemukan", null, 401);
}

$admin = $result->fetch_assoc();

if (!password_verify($password, $admin['password'])) {
    resp("error", "Password salah", null, 401);
}

$token = generateToken($admin['id'], $admin['username']);

resp("success", "Login berhasil", [
    "token"    => $token,
    "admin"    => [
        "id"       => $admin['id'],
        "nama"     => $admin['nama'],
        "username" => $admin['username'],
        "email"    => $admin['email']
    ]
]);
