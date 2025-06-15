import 'resep_detail.dart';

class Antrian {
  final int idResep;
  final String noRegistrasi;
  final double totalKeseluruhan;
  final List<ResepDetail> details;
  bool isExpanded;

  Antrian({
    required this.idResep,
    required this.noRegistrasi,
    required this.totalKeseluruhan,
    required this.details,
    this.isExpanded = false,
  });
}
