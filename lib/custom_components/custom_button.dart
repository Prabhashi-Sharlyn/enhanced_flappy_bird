import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Custom button color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounding of corners
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 35, // Increased font size for the button text
          color: Colors.white, // Set font color to white
          fontFamily: 'Game', // Set font family to 'Game'
          fontWeight: FontWeight.bold, // Set font weight to bold
        ),
      ),
    );
  }
}
