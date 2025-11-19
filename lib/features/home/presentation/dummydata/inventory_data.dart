// lib/data/inventory_data.dart

import 'dart:math';

import '../wholesaler_models/inventory_item_model.dart';

// --- ID Generator (Built-in Dart) ---
final Random _random = Random();
String generateUniqueId() {
  // Generates a high-entropy ID based on current time in microseconds 
  // and a five-digit random number.
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomPart = _random.nextInt(99999).toString().padLeft(5, '0');
  return 'ID-${timestamp}_$randomPart'; 
}
// -------------------------------------------------

// --- Dummy Data (Retailer 'dummy' Inventory) ---
final Map<String, dynamic> rawInventoryData = {
  "id_1": {
    "category": "Fruits",
    "description": "Fresh, locally sourced Apples",
    "imageUrl": "https://link.org/apples",
    "name": "Apples",
    "price": 100,
    "stockremain": 45,
    "stocksold": 23,
  },
  "id_2": {
    "category": "Vegetables",
    "description": "Crisp Carrots",
    "imageUrl": "https://link.org/carrots",
    "name": "Carrots",
    "price": 80,
    "stockremain": 75,
    "stocksold": 15,
  },
  "id_3": {
    "category": "Bakery",
    "description": "Artisan Organic Bread",
    "imageUrl": "https://link.org/bread",
    "name": "Organic Bread",
    "price": 50,
    "stockremain": 120,
    "stocksold": 80,
  },
  "id_4": {
    "category": "Pantry",
    "description": "Extra Virgin Olive Oil 5L",
    "imageUrl": "https://link.org/oliveoil",
    "name": "Olive Oil 5L",
    "price": 1500,
    "stockremain": 20,
    "stocksold": 5,
  },
};

// This mutable list represents your inventory state (the "database")
List<InventoryItemModel> inventoryList = rawInventoryData.entries.map((entry) {
  return InventoryItemModel.fromJson(entry.key, entry.value as Map<String, dynamic>);
}).toList();