<?php
// ============================================================
// surat_masuk.php — CRUD Surat Masuk
// GET    /api/surat_masuk.php           → list semua
// GET    /api/surat_masuk.php?id=1      → detail
// POST   /api/surat_masuk.php           → tambah
// PUT    /api/surat_masuk.php           → edit (body: {id,...})
// DELETE /api/surat_masuk.php?id=1      → hapus
// ============================================================

require_once 'config.php';

$auth = requireAuth();
$conn = getDB();
$method = $_SERVER['REQUEST_METHOD'];

// ── GET ─────────────────────────────────────────────────────
if ($method === 'GET') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

    if ($id > 0) {
        $stmt = $conn->prepare("SELECT * FROM surat_masuk WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $data = $stmt->get_result()->fetch_assoc();
        if (!$data) resp("error", "Data tidak ditemukan", null, 404);
        resp("success", "OK", $data);
    }

    // List dengan search & pagination
    $search = $conn->real_escape_string($_GET['search'] ?? '');
    $page   = max(1, (int)($_GET['page'] ?? 1));
    $limit  = (int)($_GET['limit'] ?? 10);
    $offset = ($page - 1) * $limit;

    $where = $search ? "WHERE no_surat LIKE '%$search%' OR asal_surat LIKE '%$search%' OR perihal LIKE '%$search%'" : "";

    $total = $conn->query("SELECT COUNT(*) as c FROM surat_masuk $where")->fetch_assoc()['c'];
    $rows  = $conn->query("SELECT * FROM surat_masuk $where ORDER BY created_at DESC LIMIT $limit OFFSET $offset")->fetch_all(MYSQLI_ASSOC);

    resp("success", "OK", [
        "total" => (int)$total,
        "page"  => $page,
        "limit" => $limit,
        "data"  => $rows
    ]);
}

// ── POST (Tambah) ────────────────────────────────────────────
if ($method === 'POST') {
    $in = json_decode(file_get_contents("php://input"), true);

    $fields = ['no_agenda','no_surat','tanggal_surat','tanggal_terima','asal_surat','perihal'];
    foreach ($fields as $f) {
        if (empty($in[$f])) resp("error", "Field '$f' wajib diisi", null, 400);
    }

    $stmt = $conn->prepare("INSERT INTO surat_masuk
        (no_agenda,no_surat,tanggal_surat,tanggal_terima,asal_surat,perihal,kepentingan,tujuan,keterangan,status,created_by)
        VALUES (?,?,?,?,?,?,?,?,?,?,?)");

    $kepentingan = $in['kepentingan'] ?? 'Biasa';
    $tujuan      = $in['tujuan']      ?? '';
    $keterangan  = $in['keterangan']  ?? '';
    $status      = $in['status']      ?? 'Belum Diproses';
    $createdBy   = $auth['id'];

    $stmt->bind_param("ssssssssssi",
        $in['no_agenda'], $in['no_surat'], $in['tanggal_surat'],
        $in['tanggal_terima'], $in['asal_surat'], $in['perihal'],
        $kepentingan, $tujuan, $keterangan, $status, $createdBy
    );

    if (!$stmt->execute()) resp("error", "Gagal menyimpan: " . $stmt->error, null, 500);

    resp("success", "Surat masuk berhasil ditambahkan", ["id" => $conn->insert_id]);
}

// ── PUT (Edit) ───────────────────────────────────────────────
if ($method === 'PUT') {
    $in = json_decode(file_get_contents("php://input"), true);
    $id = (int)($in['id'] ?? 0);
    if (!$id) resp("error", "ID wajib diisi", null, 400);

    $stmt = $conn->prepare("UPDATE surat_masuk SET
        no_agenda=?, no_surat=?, tanggal_surat=?, tanggal_terima=?,
        asal_surat=?, perihal=?, kepentingan=?, tujuan=?, keterangan=?, status=?
        WHERE id=?");

    $stmt->bind_param("ssssssssssi",
        $in['no_agenda'], $in['no_surat'], $in['tanggal_surat'],
        $in['tanggal_terima'], $in['asal_surat'], $in['perihal'],
        $in['kepentingan'], $in['tujuan'], $in['keterangan'], $in['status'], $id
    );

    if (!$stmt->execute()) resp("error", "Gagal mengupdate: " . $stmt->error, null, 500);

    resp("success", "Surat masuk berhasil diupdate");
}

// ── DELETE ───────────────────────────────────────────────────
if ($method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    if (!$id) resp("error", "ID wajib diisi", null, 400);

    $stmt = $conn->prepare("DELETE FROM surat_masuk WHERE id = ?");
    $stmt->bind_param("i", $id);
    if (!$stmt->execute()) resp("error", "Gagal menghapus", null, 500);

    resp("success", "Surat masuk berhasil dihapus");
}

resp("error", "Method tidak diizinkan", null, 405);
