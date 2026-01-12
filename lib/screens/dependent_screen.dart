import 'package:flutter/material.dart';
import '../models/membership_model.dart';

class DependentScreen extends StatelessWidget {
  final Dependent dependent;

  const DependentScreen({super.key, required this.dependent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dependent.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Photo with Hero animation
              Hero(
                tag: dependent.id,
                child: CircleAvatar(radius: 70, backgroundImage: NetworkImage(dependent.photoUrl)),
              ),
              const SizedBox(height: 20),
              Text(dependent.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(dependent.gender, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Chip(label: Text(dependent.cardStatus), backgroundColor: Color.fromARGB(255, 200, 230, 201)),
              const Spacer(),
              // Simulated QR Code section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.qr_code_2, size: 200, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Text('امسح الكود للدخول', style: TextStyle(color: Colors.grey)),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}