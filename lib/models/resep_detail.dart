class ResepDetail {
  final String idObat;
  final String? namaObat;
  final int jumlah;
  final double totalHarga;
  final String aturanPakai;

  ResepDetail({
    required this.idObat,
    required this.jumlah,
    required this.totalHarga,
    required this.aturanPakai,
    this.namaObat,
  });

  factory ResepDetail.fromJson(Map<String, dynamic> json) {
    return ResepDetail(
      idObat: json['id_obat']?.toString() ?? '',
      namaObat: json['nama_obat'],
      jumlah: int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      totalHarga:
          double.tryParse(json['total_harga']?.toString() ?? '0.0') ?? 0.0,
      aturanPakai: json['aturan_pakai']?.toString() ?? 'Tidak ada aturan',
    );
  }
}
