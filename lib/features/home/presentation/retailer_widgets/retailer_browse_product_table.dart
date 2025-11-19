import 'package:flutter/material.dart';
import '../retailer_models/retailer_product_model.dart';

class BrowseProductTable extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel product) onAddToCart;

  const BrowseProductTable({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // We use a LayoutBuilder to get the width
    return LayoutBuilder(
      builder: (context, constraints) {
        // This SingleChildScrollView handles VERTICAL scrolling
        return SingleChildScrollView(
          child: SingleChildScrollView( // This one handles HORIZONTAL scrolling
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // This forces the table to be at least as wide as the box
              constraints: BoxConstraints(minWidth: constraints.maxWidth), 
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Wholesale Price', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Stock Remain', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: products.map((product) {
                  return DataRow(
                    cells: [
                      // Product Cell
                      DataCell(Row(
                        children: [
                          Image.network(
                            product.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, e, s) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(product.name),
                        ],
                      )),
                      // Category Cell
                      DataCell(Text(product.category)),
                      // Price Cell
                      DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                      // Stock Cell
                      DataCell(Text(product.stockremain.toString())),
                      // Actions Cell
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                          tooltip: 'Add to Cart',
                          onPressed: () => onAddToCart(product),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
    );
  }
}