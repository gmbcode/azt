import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// IMPORTS
import 'package:azt/theme/dark_mode.dart'; // Import your original theme file
import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/data/firebase_user_repo.dart';
import 'features/auth/presentation/components/loading.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/auth/presentation/pages/roleselection/role_selection.dart';
import 'features/auth/presentation/pages/verification_screen.dart';
import 'features/home/presentation/pages/customer/customer_homepage.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/retailer/retailer_home_page.dart';
import 'features/home/presentation/pages/wholesaler/wholesaler_homepage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseUserRepo = FirebaseUserRepo();
  late final firebaseAuthRepo = FirebaseAuthRepo(userRepo: firebaseUserRepo);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo, userRepo: firebaseUserRepo)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        
        // --- USE ORIGINAL DARK THEME GLOBALLY ---
        theme: darkMode, 
        // ---------------------------------------

        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            if(state is Unauthenticated){
              return const AuthPage();  
            }
            if(state is Authenticated){
              final userRole = state.user.roleAllot;
              if (userRole == 'customer') return const CustomerHomePage();                
              if (userRole == 'retailer') return const RetailerHomePage();
              if (userRole == 'wholesaler') return const WholesalerHomePage();
              return const HomePage();
            }
            if(state is EmailNotVerified) return const EmailVerificationScreen();
            if(state is RoleNotSelected) return const RoleSelectionpage();
            return const LoadingScreen();
        },
        listener : (context , state) {
          if (state is AuthError){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        }
        ),
      ),
    );
  }
}