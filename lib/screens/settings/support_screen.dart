import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  final String tab; // 'privacy', 'help', 'about'
  const SupportScreen({required this.tab, super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Help & Support";
    if (tab == 'privacy') title = "Privacy Policy";
    if (tab == 'about') title = "About";

    const bgColor = Color(0xFF020617);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Content for $title goes here.\n\n(This is a placeholder for static content like legal text, FAQ lists, or app version info.)",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 1.5),
        ),
      ),
    );
  }
}
