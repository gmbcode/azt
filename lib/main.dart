import 'package:azt/features/auth/data/firebase_auth_repo.dart';
import 'package:azt/features/auth/data/firebase_user_repo.dart';
import 'package:azt/features/auth/presentation/components/loading.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:azt/features/auth/presentation/cubits/auth_states.dart';
import 'package:azt/features/auth/presentation/pages/auth_page.dart';
import 'package:azt/features/auth/presentation/pages/verification_screen.dart';
// ignore: unused_import
import 'package:azt/features/auth/presentation/pages/login_page.dart';
// ignore: unused_import
import 'package:azt/features/auth/presentation/pages/register_page.dart';
import 'package:azt/features/home/presentation/pages/home_page.dart';
import 'package:azt/theme/dark_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:azt/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //run app 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //user repo
  final firebaseUserRepo = FirebaseUserRepo();

  //auth repo
  late final firebaseAuthRepo = FirebaseAuthRepo(userRepo: firebaseUserRepo);


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
    //provide cubits to app
    providers: [  
      //auth cubit
      BlocProvider<AuthCubit>(
        create: (context)=>
         AuthCubit(authRepo: firebaseAuthRepo,userRepo: firebaseUserRepo)..checkAuth()      //calls checkauth function to check if authenticated
      ),
    ],
    
    //APP
    child: MaterialApp(
      theme: darkMode,
      home: BlocConsumer<AuthCubit,AuthState>(
        builder: (context, state) {  //check the state
            //unauthenticated -> auth page
            if(state is Unauthenticated){
              return const AuthPage();  
            }

            //authenticated -> home page; TODO: implement different redirections 
            if(state is Authenticated){
              return const HomePage();
            }
            // Email of user is not verified
            if(state is EmailNotVerified){
              return const EmailVerificationScreen();
            }
            //auth is loading
            else{
              return const LoadingScreen();
            }
        },

        //it will listen for state changes
        listener : (context , state) {
          if (state is AuthError){
            ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          }
        }
      ),
      ),
    );
  }
}
