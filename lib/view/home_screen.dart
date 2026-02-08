import 'package:flutter/material.dart';
import 'package:goru_care/view/widgets/custom_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffaf2),
      appBar: AppBar(
        backgroundColor: Color(0xffeba834),

        title: Text(
          "গরু কেয়ার",

          style: TextStyle(fontSize: 24, color: Color(0xff0d0d0c)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xff661304)),
          onPressed: () {},
          tooltip: "রিসেট",
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "বাংলা",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff661304),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // container
          Padding(padding: EdgeInsets.all(25.0), child: CustomContainer()),
        ],
      ),
    );
  }
}
