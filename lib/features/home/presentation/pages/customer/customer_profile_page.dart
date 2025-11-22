import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Watch AuthCubit for real user data
    final authState = context.watch<AuthCubit>().state;
    String email = "Guest";
    String name = "Guest";
    
    if (authState is Authenticated) {
      email = authState.user.email;
      name = authState.user.name;
    }

    return Center(
      child: SingleChildScrollView( // Prevent bottom overflow on small screens
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50, 
                backgroundColor: Colors.black12,
                child: Icon(Icons.person, size: 50, color: Colors.black54)
              ),
              const SizedBox(height: 20),
              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: (){},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text("Help & Support"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: (){},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}