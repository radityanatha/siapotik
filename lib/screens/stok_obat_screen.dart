import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/obat.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/error_widget.dart';
import '../services/api_service.dart';

class StokObatScreen extends StatefulWidget {
  const StokObatScreen({super.key});

  @override
  State<StokObatScreen> createState() => _StokObatScreenState();
}

class _StokObatScreenState extends State<StokObatScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Obat> _allObat = [];
  List<Obat> _filteredObat = [];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchObatData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchObatData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Memulai fetch data obat...');
      final List<Map<String, dynamic>> obatListJson = await ApiService.getObatList();

      if (obatListJson.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak ada data obat tersedia.';
        });
        return;
      }

      setState(() {
        _allObat = obatListJson.map((json) => Obat.fromJson(json)).toList();
        _filteredObat = _allObat;
        _isLoading = false;
        _errorMessage = '';
      });

      print('✅ Berhasil memuat ${_allObat.length} data obat');
    } catch (e) {
      print('❌ Error saat fetch data obat: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data obat: $e';
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredObat = _allObat.where((obat) {
          return obat.namaObat.toLowerCase().contains(query) ||
              obat.idObat.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau kode obat...',
                    prefixIcon: const Icon(Icons.search, size: 24),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? CustomErrorWidget(
                            errorMessage: _errorMessage,
                            onRetry: _fetchObatData,
                            title: 'Gagal Memuat Data Obat',
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchObatData,
                            child: ListView.builder(
                              itemCount: _filteredObat.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final obat = _filteredObat[index];
                                return ObatCard(obat: obat);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ObatCard extends StatelessWidget {
  final Obat obat;
  const ObatCard({super.key, required this.obat});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    Color stokColor;
    Color stokTextColor;

    if (obat.stok > 50) {
      stokColor = Colors.green.shade100;
      stokTextColor = Colors.green.shade800;
    } else if (obat.stok > 10) {
      stokColor = Colors.orange.shade100;
      stokTextColor = Colors.orange.shade800;
    } else {
      stokColor = Colors.red.shade100;
      stokTextColor = Colors.red.shade800;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obat.namaObat,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: ${obat.idObat}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: stokColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${obat.stok} ${obat.bentukSatuan}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: stokTextColor,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Harga", currencyFormatter.format(obat.harga)),
                _buildInfoColumn(
                    "Kadaluarsa",
                    obat.kadaluarsa != null
                        ? dateFormatter.format(obat.kadaluarsa!)
                        : 'N/A',
                    isEndDate: true),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper widget untuk info harga dan tanggal
  Widget _buildInfoColumn(String title, String value,
      {bool isEndDate = false}) {
    return Column(
      crossAxisAlignment:
          isEndDate ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
