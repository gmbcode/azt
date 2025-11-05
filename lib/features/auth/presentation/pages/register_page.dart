import 'package:azt/features/auth/presentation/components/my_button.dart';
import 'package:azt/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controller
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final nameController = TextEditingController();
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
              "Create an Account with Us!",
              style:TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              )
            ),
            const SizedBox(height:25),
          
            //username
            MyTextField(controller: nameController, hintText: "Username", obscureText: false),
          
            const SizedBox(height:10),
          
            //email
            MyTextField(controller: emailController, hintText: "Email", obscureText: false),

            const SizedBox(height:10),

            //password
            MyTextField(controller: pwController, hintText: "Password", obscureText: true),

            const SizedBox(height:10),

            //confirm password
            MyTextField(controller: confirmPwController, hintText: "Confirm Password", obscureText: true),

          
            const SizedBox(height: 25),

            //register button
            MyButton(
              onTap: () {},
              text: "Sign Up",
            ),

            //already have acc login now  
            Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                Text(
                  "Already Have an Account?",
                  style:
                    TextStyle(color: Theme.of(context).colorScheme.primary,),
                ),
                GestureDetector(
                  onTap: widget.togglePages,
                  child: Text(
                    " Login Now",
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