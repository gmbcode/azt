import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text("HOME"),
        actions: [
          //logout button
          IconButton(
            onPressed: (){
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            }, 
            icon: const Icon(Icons.logout),
          ),
        ]
      ),
    );
  }
}