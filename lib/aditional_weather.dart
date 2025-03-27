import 'package:flutter/material.dart';

class aditionalweatherinformation extends StatelessWidget {
  final IconData icon;
  final String condition;
  final String valcondion;
  const aditionalweatherinformation({
    super.key,
    required this.icon,
    required this.condition,
    required this.valcondion,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        SizedBox(height: 8),
        Text(condition),
        SizedBox(height: 8),
        Text(
          valcondion,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
