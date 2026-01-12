import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/membership_cubit.dart';
import '../cubits/membership_state.dart';
import 'membership_screen.dart';

class LookupScreen extends StatelessWidget {
  const LookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Member Lookup')),
      body: BlocListener<MembershipCubit, MembershipState>(
        listener: (context, state) {
          if (state is MembershipSuccess) {
            // Navigate to details on success
            Navigator.push(context, MaterialPageRoute(builder: (_) => MembershipScreen(membership: state.membership)));
          } else if (state is MembershipError) {
            // Show error message in Arabic as requested
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Membership ID', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<MembershipCubit>().fetchMembership(controller.text.trim()),
                child: const Text('بحث عن العضوية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}