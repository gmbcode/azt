import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget{
     final Color color;
     final double fontsize;
    final String text;
    final String value;
    final bool compact; // New parameter for mobile view

    const SummaryCard({
      super.key,
      required this.fontsize,
      required this.color,
      required this.text,
      required this.value,
      this.compact = false, // Default to false (Desktop size)
    });

    @override 
    Widget build(BuildContext context){
      return Container(
        // Reduce height and padding if compact is true
        height: compact ? 100 : 175, 
        padding: EdgeInsets.all(compact ? 15 : 25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      child: (
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
          children :[
            Text(
              text,
              style: TextStyle(
              fontSize: compact ? 16 : 22, // Smaller font for title
              color: Colors.white70, 
            ),
            ),

            SizedBox(height: compact ? 8 : 20), // Smaller spacing

            Text(
              value,
              style: TextStyle(
              fontSize: compact ? 30 : fontsize, // Smaller font for value
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
          ]
        )
      )
      );
    }
}