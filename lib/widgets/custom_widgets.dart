// lib/widgets/custom_widgets.dart
import 'package:flutter/material.dart';
import '../main.dart'; 

// Widget InfoCard Reusable
class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const InfoCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE8F5E8), width: 2)),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// Widget CustomSwitch (Toggle Switch Reusable)
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
      activeTrackColor: kPrimaryColor.withOpacity(0.5),
      inactiveTrackColor: const Color(0xFFCCCCCC),
      inactiveThumbColor: Colors.white,
    );
  }
}