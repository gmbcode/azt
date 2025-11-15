// lib/widgets/add_inventory_dialog.dart

import 'package:flutter/material.dart';
import '../models/retailer_inventory_item_model.dart';

class AddInventoryDialog extends StatefulWidget {
  // This function will be called when the user clicks 'Save'
  final Function(RetailerInventoryItemModel item) onSave;

  const AddInventoryDialog({super.key, required this.onSave});

  @override
  State<AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends State<AddInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all the form fields
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _handleSubmit() {
    // Check if the form is valid
    if (_formKey.currentState?.validate() ?? false) {
      
      // Create the new item from the form data
      final newItem = RetailerInventoryItemModel(
        // Create a simple unique ID. In a real app, Firebase does this.
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        stockremain: int.tryParse(_stockController.text) ?? 0,
        imageUrl: _imageUrlController.text.isNotEmpty 
            ? _imageUrlController.text 
            : 'https://placehold.co/400x400/grey/fff?text=No+Image', // Default image
        description: _descriptionController.text,
        stocksold: 0, // New items have 0 sales
      );

      // Call the onSave function from the parent page
      widget.onSave(newItem);
      
      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive dialog sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    
    return AlertDialog(
      title: const Text('Add New Inventory Item'),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 24 : 16,
        vertical: 20,
      ),
      // Make the dialog width responsive
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Product Name'),
                _buildTextField(_categoryController, 'Category'),
                _buildTextField(_priceController, 'Price', isNumber: true),
                _buildTextField(_stockController, 'Stock Remaining', isNumber: true),
                _buildTextField(_imageUrlController, 'Image URL (Optional)', isRequired: false),
                _buildTextField(_descriptionController, 'Description (Optional)', isRequired: false, maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  // Helper widget to avoid repeating code
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isRequired = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (isNumber && double.tryParse(value!) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}