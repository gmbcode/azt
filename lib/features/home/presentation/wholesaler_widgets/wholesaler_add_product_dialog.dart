// lib/widgets/add_product_dialog.dart

import 'package:flutter/material.dart';

class AddProductDialog extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onAddProduct;

  const AddProductDialog({super.key, required this.onAddProduct});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final stockRemainController = TextEditingController();
  final stockSoldController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final newProductData = {
        'name': nameController.text,
        'category': categoryController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'stockremain': int.tryParse(stockRemainController.text) ?? 0,
        'stocksold': int.tryParse(stockSoldController.text) ?? 0,
      };
      
      widget.onAddProduct(newProductData);
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockRemainController.dispose();
    stockSoldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Product Name', false),
              _buildTextField(categoryController, 'Category', false),
              _buildTextField(priceController, 'Price', true),
              _buildTextField(stockRemainController, 'Stock Remaining', true),
              _buildTextField(stockSoldController, 'Stock Sold', true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, 
          ),
          onPressed: _submitForm, 
          child: const Text('Add Product', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label.';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Please enter a valid number.';
          }
          return null;
        },
      ),
    );
  }
}