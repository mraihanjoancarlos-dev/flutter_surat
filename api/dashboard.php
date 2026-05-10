<?php
// ============================================================
// dashboard.php — GET /api/dashboard.php
// Header: Authorization: Bearer <token>
// ============================================================

require_once 'config.php';

requireAuth();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    resp("error", "Method tidak diizinkan", null, 405);
}

$conn = getDB();

// Total surat masuk
$r1  = $conn->query("SELECT COUNT(*) as total FROM surat_masuk");
$sm  = $r1->fetch_assoc()['total'];

// Total surat keluar
$r2  = $conn->query("SELECT COUNT(*) as total FROM surat_keluar");
$sk  = $r2->fetch_assoc()['total'];

// Surat masuk belum diproses
$r3  = $conn->query("SELECT COUNT(*) as total FROM surat_masuk WHERE status = 'Belum Diproses'");
$sbp = $r3->fetch_assoc()['total'];

// Surat keluar draft
$r4  = $conn->query("SELECT COUNT(*) as total FROM surat_keluar WHERE status = 'Draft'");
$skd = $r4->fetch_assoc()['total'];

// 5 surat masuk terbaru
$r5    = $conn->query("SELECT id, no_agenda, asal_surat, perihal, tanggal_terima, kepentingan, status FROM surat_masuk ORDER BY created_at DESC LIMIT 5");
$recSM = $r5->fetch_all(MYSQLI_ASSOC);

// 5 surat keluar terbaru
$r6    = $conn->query("SELECT id, no_agenda, tujuan_surat, perihal, tanggal_surat, kepentingan, status FROM surat_keluar ORDER BY created_at DESC LIMIT 5");
$recSK = $r6->fetch_all(MYSQLI_ASSOC);

resp("success", "OK", [
    "statistik" => [
        "total_surat_masuk"       => (int)$sm,
        "total_surat_keluar"      => (int)$sk,
        "sm_belum_diproses"       => (int)$sbp,
        "sk_draft"                => (int)$skd,
    ],
    "surat_masuk_terbaru"  => $recSM,
    "surat_keluar_terbaru" => $recSK,
]);
