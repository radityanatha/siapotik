import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/antrian');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/histori');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/stok');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Antrian'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histori'),
        BottomNavigationBarItem(
            icon: Icon(Icons.medication), label: 'Stok Obat'),
      ],
    );
  }
}
