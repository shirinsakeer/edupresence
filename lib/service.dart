import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupresence/bottomnav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void>register(String username,String email,String password,String confirm_password,BuildContext context)async{
  try{
    UserCredential userCredential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseFirestore.instance.collection("teachers").doc(userCredential.user!.uid).set({"name":username,"email":email,});
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created successfully")));
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }

}

Future<void>login(String email,String password,BuildContext context)async{
  try{
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login successfully")));
    Navigator.push(context,MaterialPageRoute(builder: (context) => Bottomnav(),));
  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}


Future<void>forgottpassword(String email,BuildContext context)async{
  try{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Check your inbox")));
  }catch(e)
  {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); 
  }
}