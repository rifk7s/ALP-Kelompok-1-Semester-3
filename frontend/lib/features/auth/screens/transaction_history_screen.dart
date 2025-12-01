import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionHistoryPage> {
  int selectedTab = 0;

  final List<String> tabs = ["Semua", "Belum Bayar", "Proses", "Selesai"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF0),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Transaksi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- TAB STATUS ----------------
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                bool active = selectedTab == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedTab = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? Colors.brown : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.black26),
                    ),

                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: active ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          /// ---------------- LIST TRANSAKSI ----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                buildTransactionCard(
                  title: "Gabah Kering Giling (GKG)",
                  seller: "Pak Budi",
                  date: "20 November 2025, 14:30",
                  price: "Rp650.000",
                  status: "Selesai",
                  statusColor: Colors.green,
                  buttonText: "Beli Lagi",
                  buttonColor: Colors.brown,
                ),

                buildTransactionCard(
                  title: "Gabah Kering Giling (GKG)",
                  seller: "Pak Budi",
                  date: "20 November 2025, 14:30",
                  price: "Rp650.000",
                  status: "Proses",
                  statusColor: Colors.orange,
                  buttonText: "Lacak",
                  buttonColor: Colors.brown,
                ),

                buildTransactionCard(
                  title: "Gabah Kering Giling (GKG)",
                  seller: "Pak Budi",
                  date: "20 November 2025, 14:30",
                  price: "Rp650.000",
                  status: "Batal",
                  statusColor: Colors.red,
                  buttonText: "Beli Ulang",
                  buttonColor: Colors.brown,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- CARD TRANSAKSI ----------------
  Widget buildTransactionCard({
    required String title,
    required String seller,
    required String date,
    required String price,
    required String status,
    required Color statusColor,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// STATUS BADGE
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE PLACEHOLDER
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(width: 12),

                /// TEXTS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$title 100kg",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      Text(seller, style: const TextStyle(fontSize: 13)),

                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// HARGA
            Text(
              price,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 10),

            /// BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// DETAIL button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Detail",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(width: 10),

                /// ACTION button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
