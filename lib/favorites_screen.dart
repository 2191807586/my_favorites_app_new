import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> removeFavorite(String docId) async {
    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("المفضلة")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد منتجات في المفضلة"));
          }

          final favorites = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(item['image'], width: 50, height: 50),
                  title: Text(item['title']),
                  subtitle: Text("${item['price']} \$"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await removeFavorite(favorites[index].id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم حذف المنتج من المفضلة"),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
