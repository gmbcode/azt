/*
LOGIN page UI

if logged in, go to homepage
no account, go to register page
*/

import 'package:azt/features/auth/presentation/components/my_button.dart';
import 'package:azt/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {

    //SCAFFOLD
    return Scaffold(

      //BODY
      body: Center(
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
          
            //forgot pass
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Forgot Password?", 
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )
                  
                ),
              ],
            ),

            const SizedBox(height: 25),

            //login
            MyButton(
              onTap: () {},
              text: "Login",
            ),

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
      )
    );
  }
}