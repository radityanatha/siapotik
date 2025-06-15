import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class HistoriScreen extends StatelessWidget {
  const HistoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histori"),
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
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: Text('No. 00${index + 1}'),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Nama Pasien"),
                    Text("Detail kode obat"),
                    Text("Total Harga"),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("2025-05-01"),
                    Text("Rizky"),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
