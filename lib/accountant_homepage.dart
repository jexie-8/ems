import 'package:flutter/material.dart';

class AccountantHomepage extends StatelessWidget {
  const AccountantHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
      title: Text("Accountant Homepage "),
      backgroundColor:Colors.purpleAccent
    ),
 body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                print("view event");
              },
              child: const Text('View/Edit Event'),
            ),
          ]
         )
       )
     );
   }
}
