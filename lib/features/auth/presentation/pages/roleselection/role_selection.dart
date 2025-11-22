import 'package:azt/features/auth/presentation/components/my_button.dart';
import 'package:azt/features/auth/presentation/pages/roleselection/customer_role.dart';
import 'package:azt/features/auth/presentation/pages/roleselection/retailer_role.dart';
import 'package:azt/features/auth/presentation/pages/roleselection/wholesaler_role.dart';
import 'package:flutter/material.dart';


class RoleSelectionpage extends StatefulWidget {
  const RoleSelectionpage({super.key});

  @override
  State<RoleSelectionpage> createState() => _RoleSelectionpageState();
}

class _RoleSelectionpageState extends State<RoleSelectionpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //body
      body: Center(
        
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150.0),
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
                "SELECT YOUR ROLE",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height:15),
              MyButton(
                onTap: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const customerRole(),
                    ),
                  );
                }, 
                text: "Customer (Shop Products!)",
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const retailerRole(),
                    ),
                  );
                }, 
                text: "Retailer (List and Sell Products!)",
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const wholesalerRole(),
                    ),
                  );
                }, 
                text: "Wholesaler (Sell Products!)",
              ),
          
            ],
          ),
        ),
      )
    );
  }
}