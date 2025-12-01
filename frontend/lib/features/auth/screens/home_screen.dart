import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/search_screen.dart';
import 'package:frontend/features/auth/screens/notification_screen.dart';
import 'package:frontend/features/auth/screens/hpp_screen.dart';
import 'package:frontend/features/auth/screens/product_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = '';

  final Map<String, List<Map<String, String>>> _productsByCategory = {
    'Buah': [
      {
        'name': 'Apel Segar',
        'price': 'Rp 15.000/kg',
        'stock': '50kg',
        'location': 'Sengkang, Gowa',
      },
      {
        'name': 'Mangga Harum',
        'price': 'Rp 12.000/kg',
        'stock': '75kg',
        'location': 'Makassar',
      },
    ],
    'Gabah': [
      {
        'name': 'Gabah Kering Giling',
        'price': 'Rp 6.500/kg',
        'stock': '100kg',
        'location': 'Sengkang, Gowa',
      },
      {
        'name': 'Gabah Basah',
        'price': 'Rp 5.500/kg',
        'stock': '120kg',
        'location': 'Bone',
      },
    ],
    'Sayur': [
      {
        'name': 'Tomat Segar',
        'price': 'Rp 8.000/kg',
        'stock': '60kg',
        'location': 'Maros',
      },
      {
        'name': 'Kubis Hijau',
        'price': 'Rp 5.000/kg',
        'stock': '90kg',
        'location': 'Takalar',
      },
    ],
    'Jagung': [
      {
        'name': 'Jagung Manis',
        'price': 'Rp 10.000/kg',
        'stock': '40kg',
        'location': 'Sengkang, Gowa',
      },
      {
        'name': 'Jagung Pakan',
        'price': 'Rp 7.000/kg',
        'stock': '200kg',
        'location': 'Wajo',
      },
    ],
    'Padi': [
      {
        'name': 'Padi Ciherang',
        'price': 'Rp 8.000/kg',
        'stock': '150kg',
        'location': 'Maros',
      },
      {
        'name': 'Padi Cisadane',
        'price': 'Rp 7.500/kg',
        'stock': '180kg',
        'location': 'Takalar',
      },
    ],
    'Cabe': [
      {
        'name': 'Cabe Merah Segar',
        'price': 'Rp 25.000/kg',
        'stock': '30kg',
        'location': 'Sengkang, Gowa',
      },
      {
        'name': 'Cabe Rawit',
        'price': 'Rp 35.000/kg',
        'stock': '20kg',
        'location': 'Gowa',
      },
    ],
  };

  List<Map<String, String>> get _filteredProducts {
    if (_selectedCategory.isEmpty) {
      return [
        {
          'name': 'Gabah Kering Giling',
          'price': 'Rp 6.500/kg',
          'stock': '100kg',
          'location': 'Sengkang, Gowa',
        },
        {
          'name': 'Gabah Kering Giling',
          'price': 'Rp 6.500/kg',
          'stock': '100kg',
          'location': 'Sengkang, Gowa',
        },
        {
          'name': 'Gabah Kering Giling',
          'price': 'Rp 6.500/kg',
          'stock': '100kg',
          'location': 'Sengkang, Gowa',
        },
        {
          'name': 'Gabah Kering Giling',
          'price': 'Rp 6.500/kg',
          'stock': '100kg',
          'location': 'Sengkang, Gowa',
        },
        {
          'name': 'Gabah Kering Giling',
          'price': 'Rp 6.500/kg',
          'stock': '100kg',
          'location': 'Sengkang, Gowa',
        },
        {
          'name': 'Gabah Kering Giling',
          'price': 'Rp 6.500/kg',
          'stock': '100kg',
          'location': 'Sengkang, Gowa',
        },
      ];
    }
    return _productsByCategory[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage("assets/images/logo.png"),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "PanenKi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          "Gabah",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HppPage()),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/images/hpp.png",
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Kategori",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    kategoriItem("Buah", "assets/images/gabah.jpg", () {
                      setState(() {
                        _selectedCategory = _selectedCategory == 'Buah'
                            ? ''
                            : 'Buah';
                      });
                    }, _selectedCategory == 'Buah'),
                    kategoriItem(
                      "Gabah",
                      "assets/images/gabah.jpg",
                      () {
                        setState(() {
                          _selectedCategory = _selectedCategory == 'Gabah'
                              ? ''
                              : 'Gabah';
                        });
                      },
                      _selectedCategory == 'Gabah',
                    ),
                    kategoriItem(
                      "Sayur",
                      "assets/images/gabah.jpg",
                      () {
                        setState(() {
                          _selectedCategory = _selectedCategory == 'Sayur'
                              ? ''
                              : 'Sayur';
                        });
                      },
                      _selectedCategory == 'Sayur',
                    ),
                    kategoriItem(
                      "Jagung",
                      "assets/images/gabah.jpg",
                      () {
                        setState(() {
                          _selectedCategory = _selectedCategory == 'Jagung'
                              ? ''
                              : 'Jagung';
                        });
                      },
                      _selectedCategory == 'Jagung',
                    ),
                    kategoriItem("Padi", "assets/images/gabah.jpg", () {
                      setState(() {
                        _selectedCategory = _selectedCategory == 'Padi'
                            ? ''
                            : 'Padi';
                      });
                    }, _selectedCategory == 'Padi'),
                    kategoriItem("Cabe", "assets/images/gabah.jpg", () {
                      setState(() {
                        _selectedCategory = _selectedCategory == 'Cabe'
                            ? ''
                            : 'Cabe';
                      });
                    }, _selectedCategory == 'Cabe'),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Produk",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),

              const SizedBox(height: 12),

              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return productCard(
                    context: context,
                    name: product['name']!,
                    price: product['price']!,
                    stock: product['stock']!,
                    location: product['location']!,
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget kategoriItem(
  String title,
  String imagePath,
  VoidCallback onTap,
  bool isSelected,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8A6B4F) : const Color(0xFFFFD29A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? const Color(0xFF8A6B4F) : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 15, backgroundImage: AssetImage(imagePath)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget productCard({
  required String name,
  required String price,
  required String stock,
  required String location,
  String image = "assets/images/gabah.jpg",
  BuildContext? context,
}) {
  return GestureDetector(
    onTap: () {
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              name: name,
              price: price,
              stock: stock,
              image: image,
              farmerName: "Petani Pak Abdulrahman",
              location: location,
              category: "Gabah",
              variety: "Pandan Wangi",
              harvestDate: "20 November 2025",
              description:
                  "Dengan kadar air 40%, gabah telah melewati tahap pengeringan optimal sehingga lebih stabil dan cocok untuk penyimpanan jangka menengah.",
            ),
          ),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Stok: $stock",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
