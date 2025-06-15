class Obat {
  final String idObat;
  final String namaObat;
  final int idKategori;
  final String bentukSatuan;
  final int stok;
  final double
      harga; // Menggunakan 'harga' untuk konsistensi, dari 'harga_jual'
  final DateTime? kadaluarsa;

  Obat({
    required this.idObat,
    required this.namaObat,
    required this.idKategori,
    required this.bentukSatuan,
    required this.stok,
    required this.harga,
    this.kadaluarsa,
  });

  // Factory constructor untuk membuat instance Obat dari JSON
  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      idObat: json['id_obat']?.toString() ?? '',
      namaObat: json['nama_obat']?.toString() ?? 'Tanpa Nama',

      // Menggunakan tryParse untuk keamanan tipe data
      idKategori: int.tryParse(json['id_kategori']?.toString() ?? '0') ?? 0,

      bentukSatuan: json['bentuk_satuan']?.toString() ?? '-',

      stok: int.tryParse(json['stok']?.toString() ?? '0') ?? 0,

      // Mengambil dari 'harga_jual' dan mengubahnya menjadi double
      harga: double.tryParse(json['harga_jual']?.toString() ?? '0.0') ?? 0.0,

      // Mengubah string tanggal menjadi objek DateTime, bisa null
      kadaluarsa: json['kadaluarsa'] != null
          ? DateTime.tryParse(json['kadaluarsa'])
          : null,
    );
  }
}
