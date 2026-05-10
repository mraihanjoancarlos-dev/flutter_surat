// lib/screens/surat_keluar_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class SuratKeluarScreen extends StatefulWidget {
  const SuratKeluarScreen({super.key});
  @override
  State<SuratKeluarScreen> createState() => _SuratKeluarScreenState();
}

class _SuratKeluarScreenState extends State<SuratKeluarScreen> {
  List _list    = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getSuratKeluar(search: _searchCtrl.text.trim());
      if (res['status'] == 'success') {
        setState(() { _list = res['data']['data']; _loading = false; });
      }
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Surat', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Data surat keluar ini akan dihapus permanen.',
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ApiService.deleteSuratKeluar(id);
    _load();
  }

  void _showForm([Map? data]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SuratKeluarForm(
        data: data,
        onSaved: () { Navigator.pop(context); _load(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: const Text('Surat Keluar', style: TextStyle(
          color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _load(reset: true),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Cari surat keluar...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent2))
          : _list.isEmpty
              ? const Center(child: Text('Tidak ada data', style: TextStyle(color: AppColors.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _list.length,
                  itemBuilder: (_, i) => _card(_list[i]),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent2,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _card(Map s) {
    final status  = s['status'] ?? '';
    final kep     = s['kepentingan'] ?? 'Biasa';
    final hasFile = (s['file_pdf'] ?? '').toString().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent2.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.send_outlined, color: AppColors.accent2, size: 20),
        ),
        title: Text(s['perihal'] ?? '',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${s['no_agenda']}  •  ${s['tujuan_surat']}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              _badge(status, statusColor(status)),
              const SizedBox(width: 6),
              _badge(kep, kepentinganColor(kep)),
              if (hasFile) ...[
                const SizedBox(width: 6),
                _badge('PDF', Colors.redAccent),
              ],
            ]),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.bgCard2,
          onSelected: (v) {
            if (v == 'edit')   _showForm(s);
            if (v == 'delete') _delete(int.parse(s['id'].toString()));
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Row(children: [
              Icon(Icons.edit_outlined, size: 16, color: AppColors.accent),
              SizedBox(width: 8), Text('Edit', style: TextStyle(color: AppColors.textPrimary))])),
            PopupMenuItem(value: 'delete', child: Row(children: [
              Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.redAccent))])),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }
}

// ── Form Tambah / Edit Surat Keluar ────────────────────────
class SuratKeluarForm extends StatefulWidget {
  final Map? data;
  final VoidCallback onSaved;
  const SuratKeluarForm({super.key, this.data, required this.onSaved});
  @override
  State<SuratKeluarForm> createState() => _SuratKeluarFormState();
}

class _SuratKeluarFormState extends State<SuratKeluarForm> {
  final _noAgendaCtrl   = TextEditingController();
  final _noSuratCtrl    = TextEditingController();
  final _tujuanCtrl     = TextEditingController();
  final _perihalCtrl    = TextEditingController();
  final _pengirimCtrl   = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  String _tglSurat    = '';
  String _kepentingan = 'Biasa';
  String _status      = 'Draft';
  bool   _saving      = false;

  // PDF
  File?   _pdfFile;
  String  _pdfName        = '';
  String  _existingPdfUrl = '';

  final _kepList    = ['Biasa', 'Penting', 'Sangat Penting', 'Rahasia'];
  final _statusList = ['Draft', 'Terkirim', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      final d = widget.data!;
      _noAgendaCtrl.text   = d['no_agenda']    ?? '';
      _noSuratCtrl.text    = d['no_surat']     ?? '';
      _tujuanCtrl.text     = d['tujuan_surat'] ?? '';
      _perihalCtrl.text    = d['perihal']      ?? '';
      _pengirimCtrl.text   = d['pengirim']     ?? '';
      _keteranganCtrl.text = d['keterangan']   ?? '';
      _tglSurat            = d['tanggal_surat'] ?? '';
      _kepentingan         = d['kepentingan']   ?? 'Biasa';
      _status              = d['status']        ?? 'Draft';
      _existingPdfUrl      = d['file_pdf']      ?? '';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.accent2)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _tglSurat =
      '${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}');
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() {
      _pdfFile = File(result.files.single.path!);
      _pdfName = result.files.single.name;
    });
  }

  void _removePdf() {
    setState(() {
      _pdfFile        = null;
      _pdfName        = '';
      _existingPdfUrl = '';
    });
  }

  Future<void> _save() async {
    if (_noAgendaCtrl.text.isEmpty || _noSuratCtrl.text.isEmpty ||
        _tujuanCtrl.text.isEmpty || _perihalCtrl.text.isEmpty || _tglSurat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field wajib!')));
      return;
    }
    setState(() => _saving = true);

    try {
      final body = {
        if (widget.data != null) 'id': widget.data!['id'],
        'no_agenda'    : _noAgendaCtrl.text,
        'no_surat'     : _noSuratCtrl.text,
        'tanggal_surat': _tglSurat,
        'tujuan_surat' : _tujuanCtrl.text,
        'perihal'      : _perihalCtrl.text,
        'kepentingan'  : _kepentingan,
        'pengirim'     : _pengirimCtrl.text,
        'keterangan'   : _keteranganCtrl.text,
        'status'       : _status,
      };

      Map<String, dynamic> res;

      if (_pdfFile != null) {
        res = widget.data == null
            ? await ApiService.addSuratKeluarWithFile(body, _pdfFile!)
            : await ApiService.updateSuratKeluarWithFile(body, _pdfFile!);
      } else {
        if (_existingPdfUrl.isEmpty && widget.data != null) {
          body['hapus_file'] = '1';
        }
        res = widget.data == null
            ? await ApiService.addSuratKeluar(body)
            : await ApiService.updateSuratKeluar(body);
      }

      if (res['status'] == 'success') {
        widget.onSaved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menyimpan')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Tidak dapat terhubung ke server')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.data != null;
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(isEdit ? 'Edit Surat Keluar' : 'Tambah Surat Keluar',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(children: [
                _field('No. Agenda *', _noAgendaCtrl),
                _field('No. Surat *', _noSuratCtrl),
                _field('Tujuan Surat *', _tujuanCtrl),
                _field('Perihal *', _perihalCtrl),
                _datePicker('Tanggal Surat *', _tglSurat, _pickDate),
                _field('Pengirim', _pengirimCtrl),
                _field('Keterangan', _keteranganCtrl, maxLines: 3),
                _dropdown('Kepentingan', _kepentingan, _kepList,
                  (v) => setState(() => _kepentingan = v!)),
                _dropdown('Status', _status, _statusList,
                  (v) => setState(() => _status = v!)),

                // ── Upload PDF ────────────────────────────
                _pdfPicker(),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                      borderRadius: BorderRadius.circular(14)),
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Surat',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── PDF Picker Widget ───────────────────────────────────
  Widget _pdfPicker() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('File PDF (Wajib)', style: TextStyle(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),

        if (_pdfFile != null || _existingPdfUrl.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pdfFile != null ? _pdfName : _existingPdfUrl.split('/').last,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _removePdf,
                ),
              ],
            ),
          ),

        GestureDetector(
          onTap: _pickPdf,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _pdfFile != null
                    ? Colors.redAccent.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_outlined,
                  color: _pdfFile != null ? Colors.redAccent : AppColors.textMuted,
                  size: 20),
                const SizedBox(width: 8),
                Text(
                  _pdfFile != null ? 'Ganti File PDF' : 'Pilih File PDF',
                  style: TextStyle(
                    color: _pdfFile != null ? Colors.redAccent : AppColors.textMuted,
                    fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 4),
        const Text('Maks. 5MB • Format: PDF',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    ),
  );

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration()),
    ]));

  Widget _datePicker(String label, String value, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52, padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.bgCard2, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 16),
            const SizedBox(width: 10),
            Text(value.isEmpty ? 'Pilih tanggal...' : value,
              style: TextStyle(color: value.isEmpty ? AppColors.textMuted : AppColors.textPrimary, fontSize: 14)),
          ]),
        ),
      ),
    ]));

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value, dropdownColor: AppColors.bgCard2,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(),
        items: items.map((e) => DropdownMenuItem(value: e,
          child: Text(e, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
        onChanged: onChanged),
    ]));

  @override
  void dispose() {
    _noAgendaCtrl.dispose(); _noSuratCtrl.dispose();
    _tujuanCtrl.dispose(); _perihalCtrl.dispose();
    _pengirimCtrl.dispose(); _keteranganCtrl.dispose();
    super.dispose();
  }
}

// ── Helper Functions ───────────────────────────────────────
Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'terkirim':    return Colors.green;
    case 'dibatalkan':  return Colors.redAccent;
    case 'draft':       return Colors.grey;
    default:            return Colors.orange;
  }
}

Color kepentinganColor(String kep) {
  switch (kep.toLowerCase()) {
    case 'penting':        return Colors.redAccent;
    case 'sangat penting': return Colors.red;
    case 'rahasia':        return Colors.purple;
    default:               return Colors.teal;
  }
}