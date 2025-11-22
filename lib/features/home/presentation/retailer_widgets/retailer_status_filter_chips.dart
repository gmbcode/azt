import 'package:flutter/material.dart';

class StatusFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const StatusFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.map((filter) {
        final bool isSelected = selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                onSelected(filter);
              }
            },
            backgroundColor: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[100],
            selectedColor: Colors.orange.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? Colors.orange[800] : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.orange : Colors.grey[300]!,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}