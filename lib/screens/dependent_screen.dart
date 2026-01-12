import 'package:flutter/material.dart';
import '../models/family_model.dart'; 

class DependentScreen extends StatelessWidget {
  final FamilyMemberModel dependent; 

  const DependentScreen({super.key, required this.dependent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dependent.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Hero(
                  tag: dependent.id,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(dependent.photoUrl),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(dependent.name, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Chip(label: Text(dependent.cardStatus)),
              const SizedBox(height: 40),
              // QR Code Placeholder
              const Icon(Icons.qr_code_2, size: 200),
              const Text("Scan for Access"),
            ],
          ),
        ),
      ),
    );
  }
}