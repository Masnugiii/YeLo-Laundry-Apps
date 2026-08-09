import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Bagaimana cara membuat pickup request?'),
            subtitle: Text('Buka menu Pickup, pilih order dan alamat, lalu kirim request.'),
          ),
          ListTile(
            title: Text('Bagaimana melacak order?'),
            subtitle: Text('Buka detail order lalu pilih Lacak Proses Laundry.'),
          ),
          ListTile(
            title: Text('Hubungi customer service'),
            subtitle: Text('WhatsApp: +62 812-3456-7890'),
          ),
        ],
      ),
    );
  }
}
