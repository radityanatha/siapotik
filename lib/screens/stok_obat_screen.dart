import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class StokObatScreen extends StatelessWidget {
  const StokObatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> obat = [
      {'nama': 'Cendo Xitrol Tetes', 'kode': 'CEN001'},
      {'nama': 'Lidocaine Gel', 'kode': 'LID001'},
      {'nama': 'Amoxicillin 500mg', 'kode': 'AMX001'},
      {'nama': 'Amlodipine 5mg', 'kode': 'AML001'},
      {'nama': 'Paracetamol', 'kode': 'PAR001'},
      {'nama': 'Vitamin C 1000mg', 'kode': 'VITC001'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok Obat"),
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
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Obat',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: obat.length,
                  itemBuilder: (context, index) {
                    final item = obat[index];
                    return ListTile(
                      title: Text(item['nama']!),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['kode']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
