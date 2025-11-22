import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- THEME & OPTIONS ---
import 'package:azt/theme/dark_mode.dart'; 
import 'firebase_options.dart';

// --- AUTH ---
import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/data/firebase_user_repo.dart';
import 'features/auth/presentation/components/loading.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/auth/presentation/pages/roleselection/role_selection.dart';
import 'features/auth/presentation/pages/verification_screen.dart';

// --- RETAILER ---
import 'features/home/presentation/pages/retailer/retailer_home_page.dart';
import 'features/retailer/data/repos/retailer_repo.dart'; // New Import

// --- WHOLESALER ---
import 'features/home/presentation/pages/wholesaler/wholesaler_homepage.dart';

// --- CUSTOMER ---
import 'features/home/presentation/pages/customer/customer_homepage.dart';

// --- GENERIC HOME ---
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Initialize Repositories
  final firebaseUserRepo = FirebaseUserRepo();
  late final firebaseAuthRepo = FirebaseAuthRepo(userRepo: firebaseUserRepo);
  final retailerRepo = RetailerRepo(); // Initialize Retailer Repo

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Provide RetailerRepo globally so it can be accessed by RetailerCubit anywhere
        RepositoryProvider.value(value: retailerRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          // AuthCubit is needed globally to check login status
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepo: firebaseAuthRepo, 
              userRepo: firebaseUserRepo
            )..checkAuth(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          
          // Apply your existing Dark Mode Theme
          theme: darkMode, 

          home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message))
                );
              }
            },
            builder: (context, state) {
              // 1. Not Logged In
              if (state is Unauthenticated) {
                return const AuthPage();  
              }
              
              // 2. Logged In & Verified
              if (state is Authenticated) {
                final userRole = state.user.roleAllot;
                
                // Route based on Role
                if (userRole == 'customer') return const CustomerHomePage();                
                if (userRole == 'retailer') return const RetailerHomePage();
                if (userRole == 'wholesaler') return const WholesalerHomePage();
                
                // Fallback if role exists but doesn't match known types (shouldn't happen)
                return const HomePage();
              }
              
              // 3. Email Not Verified
              if (state is EmailNotVerified) {
                return const EmailVerificationScreen();
              }
              
              // 4. Role Not Selected
              if (state is RoleNotSelected) {
                return const RoleSelectionpage();
              }
              
              // 5. Loading / Initial
              return const LoadingScreen();
            },
          ),
        ),
      ),
    );
  }
}