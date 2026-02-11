import 'package:edupresence/login.dart';
import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          
          decoration: BoxDecoration(
            
          image: DecorationImage(image: AssetImage("assets/bg.jpeg"),fit: BoxFit.fill),
              
            border: Border.all(color: Colors.white)
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          
          Image.asset("assets/logo.png",height: 200,width: 200),
        
        Container(
  margin: const EdgeInsets.symmetric(horizontal: 25),
  padding: const EdgeInsets.all(25),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 8),
      )
    ],
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [




      //Username

      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email),
          hintText: "Username",
          filled: true,
          fillColor: Colors.grey.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 20),
      
      /// Email Field
      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email),
          hintText: "Email",
          filled: true,
          fillColor: Colors.grey.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 20),

      /// Password Field
      TextField(
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          hintText: "Password",
          filled: true,
          fillColor: Colors.grey.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 15),



      //conform password
      /// Password Field
      TextField(
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          hintText: "Confirm Password",
          filled: true,
          fillColor: Colors.grey.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 15),

     

      const SizedBox(height: 10),

      /// Login Button
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(167, 71, 159, 27),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 18,color: Colors.white),
          ),
        ),
      ),

       SizedBox(height: 15),

     Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
                  },
                  child: Text("Login",style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
    ],
  ),
),


        ],
        
           
          ),
        ),
      ),
    );
  }
}