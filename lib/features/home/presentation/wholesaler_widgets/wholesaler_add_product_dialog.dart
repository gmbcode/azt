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
  final stockController = TextEditingController();
  final moqController = TextEditingController();
  final descController = TextEditingController();
  // 1. Added Controller for Image URL
  final imageController = TextEditingController(); 

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 2. Use the input URL, fallback to placeholder only if empty
      String finalImageUrl = imageController.text.trim();
      if (finalImageUrl.isEmpty) {
        finalImageUrl = 'https://placehold.co/400?text=${nameController.text}';
      }

      widget.onAddProduct({
        'name': nameController.text,
        'category': categoryController.text,
        'price': priceController.text,
        'stock': stockController.text,
        'moq': moqController.text,
        'description': descController.text,
        'imageUrl': finalImageUrl, // 3. Store the URL here
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController, 
                decoration: const InputDecoration(labelText: 'Name'), 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              TextFormField(
                controller: categoryController, 
                decoration: const InputDecoration(labelText: 'Category'), 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              TextFormField(
                controller: priceController, 
                decoration: const InputDecoration(labelText: 'Price'), 
                keyboardType: TextInputType.number, 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              TextFormField(
                controller: stockController, 
                decoration: const InputDecoration(labelText: 'Stock'), 
                keyboardType: TextInputType.number, 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              TextFormField(
                controller: moqController, 
                decoration: const InputDecoration(labelText: 'MOQ (Min Order Qty)'), 
                keyboardType: TextInputType.number, 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              // 4. Added Image URL Field
              TextFormField(
                controller: imageController, 
                decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
                keyboardType: TextInputType.url,
              ),
              TextFormField(
                controller: descController, 
                decoration: const InputDecoration(labelText: 'Description')
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: _submit, 
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), 
          child: const Text('Add', style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }
}