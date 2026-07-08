import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/product.dart';
import 'services/api_service.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  List<bool> favorites = [];

  Future<void> saveFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('favorites').add({
      'userId': user.uid,
      'productId': product.id,
      'title': product.title,
      'price': product.price,
      'image': product.image,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("صفحة المنتجات"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: apiService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ"));
          }

          final products = snapshot.data!;

          if (favorites.length != products.length) {
            favorites = List.generate(products.length, (index) => false);
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                leading: Image.network(product.image, width: 50, height: 50),
                title: Text(product.title),
                subtitle: Text("${product.price} \$"),
                trailing: IconButton(
                  icon: Icon(
                    favorites[index] ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    setState(() {
                      favorites[index] = !favorites[index];
                    });

                    if (favorites[index]) {
                      await saveFavorite(product);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          favorites[index]
                              ? "تمت إضافة ${product.title} للمفضلة"
                              : "تمت إزالة ${product.title} من المفضلة",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
