/*
LOGIN page UI

if logged in, go to homepage
no account, go to register page
*/

import 'package:azt/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:azt/features/auth/presentation/components/my_button.dart';
import 'package:azt/features/auth/presentation/components/my_textfield.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text controller
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  //auth cubit
  late final authCubit = context.read<AuthCubit>();

  //LOGIN button pressed
  void login(){
    //prepare email and password
    final String email = emailController.text;
    final String pw = pwController.text;

    //ensure fields are filled
    if (email.isNotEmpty && pw.isNotEmpty){
      authCubit.login(email, pw);
    }

    //fields are empty
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Enter Both Email and Password!")));
    }
  }
  void openForgotPasswordBox(){
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
          title: Text("Forgot Password"),
          content: MyTextField(
            controller: emailController, hintText: "Enter email", obscureText: false
          ),
          actions: [
            //cancel button
            TextButton(
              onPressed: ()=>Navigator.pop(context), 
              child: const Text("Cancel"),
            ),

            //reset button
            TextButton(
              onPressed: () async {
                  String message = await authCubit.forgotPassword(emailController.text);
                  if (message == "Password reset email sent!"){
                    Navigator.pop(context);
                    emailController.clear();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
              },

              child: const Text("Reset"),
            ),
          ]
      ),
    );
  }


  //BUILD UI
  @override
  Widget build(BuildContext context) {

    //SCAFFOLD
    return Scaffold(

      //BODY
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
        
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 
              //logo
              Icon(
                Icons.lock_open,
                size:80,
                color: Theme.of(context).colorScheme.primary,
              ),
            
              const SizedBox(height:25),
        
              //name of app
              Text(
                "S H O P P I N G   A P P ",
                style:TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inversePrimary,
                )
              ),
            
              const SizedBox(height:25),
            
              //email
              MyTextField(controller: emailController, hintText: "Email", obscureText: false),
        
              const SizedBox(height:10),
        
              //password
              MyTextField(controller: pwController, hintText: "Password", obscureText: true),
        
              const SizedBox(height:10),
        
              //forgot pass
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: ()=> openForgotPasswordBox(),
                    child: Text(
                      "Forgot Password?", 
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )
                      
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 10),
        
              //login
              MyButton(
                onTap: login,
                text: "Login",
              ),
        
              const SizedBox(height: 10),
        
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.tertiary,
                  ), 
                ), 
              Text("Or sign in with"),
              Expanded(
                child: Divider(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              ],
              ),
        
              const SizedBox(height: 15),
        
              
              // oauth using google
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //google button
                  MyGoogleSignInButton(
                    onTap: () async {
                      authCubit.signInWithGoogle();
                    }
                  )
        
                ],
              ),
        
              const SizedBox(height: 25),
        
              //dont have acc sign in later
              Row(
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  Text(
                    "Dont Have an Account?",
                    style:
                      TextStyle(color: Theme.of(context).colorScheme.primary,),
                  ),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      " Register Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary,
                      ), 
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      )
    );
  }
}