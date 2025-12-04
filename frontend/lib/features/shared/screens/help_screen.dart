import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          "Bantuan",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            helpCard("FAQ (Pertanyaan Umum)", Icons.help_outline),
            const SizedBox(height: 12),
            helpCard("Hubungi CS", Icons.phone_in_talk_outlined),
            const SizedBox(height: 12),
            helpCard("Laporan Masalah", Icons.report_problem_outlined),
            const SizedBox(height: 12),
            helpCard("Kebijakan Pengguna", Icons.description_outlined),
          ],
        ),
      ),
    );
  }

  Widget helpCard(String title, IconData icon) {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFE7C0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
