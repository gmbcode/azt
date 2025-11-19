// lib/widgets/add_product_dialog.dart

import 'package:flutter/material.dart';

class AddProductDialog extends StatelessWidget {
  const AddProductDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // These controllers would be used to get the text from the fields
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final stockRemainController = TextEditingController();
    final stockSoldController = TextEditingController();

    return AlertDialog(
      title: const Text('Add New Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stockRemainController,
              decoration: const InputDecoration(
                labelText: 'Stock Remaining',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stockSoldController,
              decoration: const InputDecoration(
                labelText: 'Stock Sold',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Match your button color
          ),
          onPressed: () {
            //
            // THIS IS WHERE YOUR FRIEND WILL ADD THE BACKEND LOGIC
            // For example:
            //
            // final newProduct = {
            //   'name': nameController.text,
            //   'category': categoryController.text,
            //   'price': int.tryParse(priceController.text) ?? 0,
            //   'stockremain': int.tryParse(stockRemainController.text) ?? 0,
            //   'stocksold': int.tryParse(stockSoldController.text) ?? 0,
            // };
            //
            // print("Adding new product: $newProduct");
            //
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Add Product', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}