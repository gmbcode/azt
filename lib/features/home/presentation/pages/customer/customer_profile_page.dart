import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String email = "Loading...";
    String name = "Loading...";
    
    if (authState is Authenticated) {
      email = authState.user.email;
      name = authState.user.name;
    }

    return SingleChildScrollView( // Added ScrollView to fix overflow
      child: Center(
        child: Container(
          width: 400,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 20),
              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings not implemented"))),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text("Help & Support"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Support coming soon"))),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}