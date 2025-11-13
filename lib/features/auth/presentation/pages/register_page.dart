import 'package:azt/features/auth/presentation/components/my_button.dart';
import 'package:azt/features/auth/presentation/components/my_textfield.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azt/features/auth/domain/validators/username_validator.dart';

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

  //register button pressed
  void register(){
    //prepare information to store
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    //validate username
    final usernameError = UsernameValidator.validate(name);
    if (usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(usernameError)));
      return;
    }

    //ensure fields entered arent empty
    if (email.isNotEmpty && name.isNotEmpty && pw.isNotEmpty && confirmPw.isNotEmpty){
      
      //pw matches confirmpw
      if(pw == confirmPw){
        authCubit.register(name, email, pw);          //registers user
      }

      //pw doesnt match
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!!")));
      }
    }
    //fields are empty
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter all Fields!")));
    }
  }
  
  //dispose memory controllers 
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }
  
  //build ui
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
              onTap: register,
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