import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.white,
        foregroundColor: Colors.lightBlue,

        title: Row(
          children: [
            Icon(
              Icons.school, // icon before EduPresence
              color: Colors.lightBlue,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              "EduPresence",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Icon(Icons.notifications),
          SizedBox(width: 20),
          Icon(Icons.person),
          SizedBox(width: 20),
          
        ],
      
      ),
     floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.person_add_alt),
        
      ),
    );
  }
}