import 'package:edupresence/login.dart';
import 'package:edupresence/service.dart';
import 'package:flutter/material.dart';

class Forgottpassword extends StatefulWidget {
  const Forgottpassword({super.key});

  @override
  State<Forgottpassword> createState() => _ForgottpasswordState();
}

class _ForgottpasswordState extends State<Forgottpassword> {
  TextEditingController emailcontroller=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      /// Email Field
      TextField(
        controller: emailcontroller,
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
          onPressed: () {
      
            forgottpassword(emailcontroller.text, context);      emailcontroller.clear(); },
          child: const Text(
            "Send Link",
            style: TextStyle(fontSize: 18,color: Colors.white),
          ),
        ),
      ),

       SizedBox(height: 15),

       Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
                  },
                  child: Text("Back to login",style: TextStyle(fontWeight: FontWeight.bold))),
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