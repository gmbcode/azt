import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget{
     final Color color;
     final double fontsize;
    final String text;
    final String value;

    const SummaryCard({
      super.key,
      required this.fontsize,
      required this.color,
      required this.text,
      required this.value,

    });

    Widget build(BuildContext context){
      return Container(
        height: 175,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      child: (
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children :[
            Text(
              text,
              style: const TextStyle(
              fontSize: 22,
              color: Colors.white70, // Slightly lighter color for the title
            ),
            ),

            const SizedBox(height: 20),

            Text(
              value,
              style: TextStyle(
              fontSize: fontsize, // Larger, bold font for the value
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),),
          ]
        )
      )


      );
    }



}