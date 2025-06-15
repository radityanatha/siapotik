class ResepDetail {
  final String idObat;
  final String? namaObat;
  final int jumlah;
  final double totalHarga;

  ResepDetail({
    required this.idObat,
    required this.jumlah,
    required this.totalHarga,
    this.namaObat,
  });

  factory ResepDetail.fromJson(Map<String, dynamic> json) {
    return ResepDetail(
      idObat: json['id_obat'],
      namaObat: json['nama_obat'],
      jumlah: int.parse(json['jumlah'].toString()),
      totalHarga: double.parse(json['total_harga'].toString()),
    );
  }
}
