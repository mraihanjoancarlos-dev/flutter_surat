<?php
// ============================================================
// surat_keluar.php — CRUD Surat Keluar
// ============================================================

require_once 'config.php';

$auth   = requireAuth();
$conn   = getDB();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

    if ($id > 0) {
        $stmt = $conn->prepare("SELECT * FROM surat_keluar WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $data = $stmt->get_result()->fetch_assoc();
        if (!$data) resp("error", "Data tidak ditemukan", null, 404);
        resp("success", "OK", $data);
    }

    $search = $conn->real_escape_string($_GET['search'] ?? '');
    $page   = max(1, (int)($_GET['page'] ?? 1));
    $limit  = (int)($_GET['limit'] ?? 10);
    $offset = ($page - 1) * $limit;

    $where = $search ? "WHERE no_surat LIKE '%$search%' OR tujuan_surat LIKE '%$search%' OR perihal LIKE '%$search%'" : "";

    $total = $conn->query("SELECT COUNT(*) as c FROM surat_keluar $where")->fetch_assoc()['c'];
    $rows  = $conn->query("SELECT * FROM surat_keluar $where ORDER BY created_at DESC LIMIT $limit OFFSET $offset")->fetch_all(MYSQLI_ASSOC);

    resp("success", "OK", [
        "total" => (int)$total,
        "page"  => $page,
        "limit" => $limit,
        "data"  => $rows
    ]);
}

if ($method === 'POST') {
    $in = json_decode(file_get_contents("php://input"), true);

    $fields = ['no_agenda','no_surat','tanggal_surat','tujuan_surat','perihal'];
    foreach ($fields as $f) {
        if (empty($in[$f])) resp("error", "Field '$f' wajib diisi", null, 400);
    }

    $stmt = $conn->prepare("INSERT INTO surat_keluar
        (no_agenda,no_surat,tanggal_surat,tujuan_surat,perihal,kepentingan,pengirim,keterangan,status,created_by)
        VALUES (?,?,?,?,?,?,?,?,?,?)");

    $kepentingan = $in['kepentingan'] ?? 'Biasa';
    $pengirim    = $in['pengirim']    ?? '';
    $keterangan  = $in['keterangan'] ?? '';
    $status      = $in['status']     ?? 'Draft';
    $createdBy   = $auth['id'];

    $stmt->bind_param("sssssssssi",
        $in['no_agenda'], $in['no_surat'], $in['tanggal_surat'],
        $in['tujuan_surat'], $in['perihal'],
        $kepentingan, $pengirim, $keterangan, $status, $createdBy
    );

    if (!$stmt->execute()) resp("error", "Gagal menyimpan: " . $stmt->error, null, 500);

    resp("success", "Surat keluar berhasil ditambahkan", ["id" => $conn->insert_id]);
}

if ($method === 'PUT') {
    $in = json_decode(file_get_contents("php://input"), true);
    $id = (int)($in['id'] ?? 0);
    if (!$id) resp("error", "ID wajib diisi", null, 400);

    $stmt = $conn->prepare("UPDATE surat_keluar SET
        no_agenda=?, no_surat=?, tanggal_surat=?, tujuan_surat=?,
        perihal=?, kepentingan=?, pengirim=?, keterangan=?, status=?
        WHERE id=?");

    $stmt->bind_param("sssssssssi",
        $in['no_agenda'], $in['no_surat'], $in['tanggal_surat'],
        $in['tujuan_surat'], $in['perihal'],
        $in['kepentingan'], $in['pengirim'], $in['keterangan'], $in['status'], $id
    );

    if (!$stmt->execute()) resp("error", "Gagal mengupdate: " . $stmt->error, null, 500);

    resp("success", "Surat keluar berhasil diupdate");
}

if ($method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    if (!$id) resp("error", "ID wajib diisi", null, 400);

    $stmt = $conn->prepare("DELETE FROM surat_keluar WHERE id = ?");
    $stmt->bind_param("i", $id);
    if (!$stmt->execute()) resp("error", "Gagal menghapus", null, 500);

    resp("success", "Surat keluar berhasil dihapus");
}

resp("error", "Method tidak diizinkan", null, 405);
