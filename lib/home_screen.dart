import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("صفحة المنتجات"),
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("رقم الخدمة: 0910000000"), // رقم الخدمة المطلوب
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text("منتج رقم ${index + 1}"),
            trailing: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.yellow,
              ), // الزر الأصفر
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تمت الإضافة للمفضلة")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
