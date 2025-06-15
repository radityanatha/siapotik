import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/bottom_nav.dart';
import '../models/resep_detail.dart';

class AntrianScreen extends StatefulWidget {
  const AntrianScreen({super.key});

  @override
  State<AntrianScreen> createState() => _AntrianScreenState();
}

class _AntrianScreenState extends State<AntrianScreen>
    with SingleTickerProviderStateMixin {
  List<ResepDetail> resepList = [];
  double totalHarga = 0;
  String status = "Lunas";
  final String nomorSekarang = '001';
  bool _showDetail = true;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    fetchResep(nomorSekarang);
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _heightFactor =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchResep(String noRegistrasi) async {
    final url = Uri.parse(
        'http://192.168.9.166/api_apotik/get_resep_detail_join.php?no_registrasi=$noRegistrasi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      double total = 0;

      final result = data.map((json) {
        final item = ResepDetail.fromJson(json);
        total += item.totalHarga;
        return item;
      }).toList();

      setState(() {
        resepList = result;
        totalHarga = total;
      });
    } else {
      throw Exception("Gagal mengambil data resep.");
    }
  }

  void toggleDetail() {
    setState(() {
      _showDetail = !_showDetail;
      if (_showDetail) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Antrian"),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) {
            if (value == 'profil') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Profil belum tersedia')),
              );
            } else if (value == 'logout') {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profil', child: Text('Profil')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: InfoCard(title: "Antrian", value: nomorSekarang)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: InfoCard(title: "Total Antrian", value: "006")),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: toggleDetail,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text("Antrian Resep",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                Icon(_showDetail
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                nomorSekarang,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            SizeTransition(
                              sizeFactor: _heightFactor,
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Expanded(
                                                flex: 4,
                                                child: Text("Obat",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Expanded(
                                                flex: 3,
                                                child: Text("Jumlah",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Expanded(
                                                flex: 3,
                                                child: Text("Harga",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ],
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          height: 120,
                                          child: ListView.builder(
                                            itemCount: resepList.length,
                                            itemBuilder: (context, index) {
                                              final r = resepList[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                            r.namaObat ??
                                                                r.idObat)),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                            '${r.jumlah} (pcs)')),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                            'Rp. ${r.totalHarga.toStringAsFixed(0)}')),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Total",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "Rp.${totalHarga.toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text("Status",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(status,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.red),
                                          onPressed: () {}),
                                      IconButton(
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.indigo),
                                          onPressed: () {}),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.indigo),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Catatan tambahan / informasi lainnya bisa ditampilkan di sini.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 28, color: Colors.white)),
        ],
      ),
    );
  }
}
