import 'package:flutter/material.dart';
import '../models/membership_model.dart';
import 'dependent_screen.dart';

class MembershipScreen extends StatelessWidget {
  final Membership membership;

  const MembershipScreen({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العضوية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Member Info Card
            _buildMainCard(context),
            const SizedBox(height: 24),

            // Wives Section
            if (membership.wives.isNotEmpty) ...[
              _buildSectionTitle(context, 'الزوجات'),
              ...membership.wives.map((wife) => _buildDependentTile(context, wife)),
              const SizedBox(height: 20),
            ],

            // Children Section
            if (membership.children.isNotEmpty) ...[
              _buildSectionTitle(context, 'الأبناء'),
              ...membership.children.map((child) => _buildDependentTile(context, child)),
            ],
          ],
        ),
      ),
    );
  }

  // Build the primary membership card
  Widget _buildMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primary]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(membership.photoUrl)),
          const SizedBox(height: 12),
          Text(membership.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(membership.job, style: TextStyle(color: Color.fromARGB(255, 255, 255, 100))),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem('رقم العضوية', membership.membershipId),
              _infoItem('الحالة', membership.membershipStatus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
    );
  }

  Widget _buildDependentTile(BuildContext context, Dependent dependent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(dependent.photoUrl)),
        title: Text(dependent.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dependent.cardStatus),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DependentScreen(dependent: dependent))),
      ),
    );
  }
}