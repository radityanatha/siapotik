import 'resep_detail.dart';

class Riwayat {
  final int idRiwayat;
  final int idResep;
  final String noRegistrasi;
  final DateTime tanggalSelesai;
  final String status;
  final double totalKeseluruhan;
  final List<ResepDetail> details;

  Riwayat({
    required this.idRiwayat,
    required this.idResep,
    required this.noRegistrasi,
    required this.tanggalSelesai,
    required this.status,
    required this.totalKeseluruhan,
    required this.details,
  });
}
