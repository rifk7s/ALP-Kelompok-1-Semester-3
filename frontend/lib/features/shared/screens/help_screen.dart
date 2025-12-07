import 'package:flutter/material.dart';
import 'package:frontend/core/theme/theme.dart';
import 'report_screen.dart';
import 'chat_detail_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Bantuan & Dukungan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            helpCard("Hubungi CS", Icons.phone_in_talk_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(
                    name: 'Customer Service',
                    image: 'assets/images/logo.png',
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            helpCard("Laporan Masalah", Icons.report_problem_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportPage()),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget helpCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
