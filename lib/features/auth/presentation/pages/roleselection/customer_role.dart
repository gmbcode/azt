import 'package:azt/features/auth/presentation/components/my_button.dart';
import 'package:azt/features/auth/presentation/components/my_textfield.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:azt/features/auth/presentation/pages/roleselection/role_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class customerRole extends StatefulWidget {
  const customerRole({super.key});

  @override
  State<customerRole> createState() => _customerRoleState();
}

class _customerRoleState extends State<customerRole> {
  //text controller
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  bool _isLoading = false;
  
  void register() async {
    //prepare information to store
    final String address = addressController.text;
    final String pincode = pincodeController.text;

    // This regex checks if the string contains EXACTLY 6 digits
    final bool isPincodeValid = RegExp(r'^[0-9]{6}$').hasMatch(pincode);

    //fields are empty
    if(address.isEmpty || pincode.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter all Fields!")));
    }

    if (!isPincodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pincode must be exactly 6 digits!!")),
      );
      return;
    }

    if(address.length>200){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address is too Long!")),
      );
      return;
    }
    
    //save role selection
    setState(() => _isLoading = true);
    try{
      final authCubit = context.read<AuthCubit>();
      await authCubit.saveRoleSelection('customer', address, pincode);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Customer profile created successfully!")),
        );
        setState(() => _isLoading = false);
      }
    } catch(e){
      if (mounted) {  
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        setState(() => _isLoading = false);
      }
    } 
  }
  
  //dispose memory controllers 
  @override
  void dispose() {
    addressController.dispose();
    pincodeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //body
      body: Center(
        
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "S H O P P I N G   A P P",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "Customer Role",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height:15),

              //taking address,pincode
              MyTextField(controller: addressController , hintText: "Enter your address", obscureText: false),  
              const SizedBox(height:15),
              MyTextField(controller: pincodeController , hintText: "Enter your pincode", obscureText: false),
              const SizedBox(height:25),
              
              _isLoading
                ? const CircularProgressIndicator()
                : MyButton(onTap: register, text: "Confirm Details!"),
              
              const SizedBox(height:10),
              //going back 
              Row(
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  Text(
                    "Want a Different role?",
                    style:
                      TextStyle(color: Theme.of(context).colorScheme.primary,),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => const RoleSelectionpage(),
                        ),
                      );
                    },
                    child: Text(
                      " Click Here to Go Back",
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
