import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
          
          Image.asset("assets/logo.png",height: 300,width: 200),
          
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

      /// Forgot Password
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          child: const Text("Forgot Password?"),
        ),
      ),

      const SizedBox(height: 10),

      /// Login Button
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(167, 57, 128, 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {},
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),

      const SizedBox(height: 15),

      const Text(
        "Login as Teacher or Student",
        style: TextStyle(color: Colors.grey),
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
