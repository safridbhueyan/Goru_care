import 'package:flutter/material.dart';
import 'package:goru_care/controller/home_controller.dart';
import 'package:goru_care/view/widgets/custom_container.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffaf2),
      appBar: AppBar(
        backgroundColor: Color(0xffeba834),

        title: Consumer<HomeController>(
          builder: (context, controller, _) {
            return Text(
              "গরু কেয়ার",

              style: TextStyle(fontSize: 24, color: Color(0xff0d0d0c)),
            );
          },
        ),
        centerTitle: true,
        leading: Consumer<HomeController>(
          builder: (context, controller, _) {
            return IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xff661304)),
              onPressed: () {},
              tooltip: "রিসেট",
            );
          },
        ),
        actions: [
          Consumer<HomeController>(
            builder: (context, controller, _) {
              final isEnglish = controller.isEnglish;
              return TextButton(
                onPressed: () {
                  controller.toggle();
                },
                child: Text(
                  isEnglish == true ? "ENG" : "বাংলা",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff661304),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // container
          Padding(padding: EdgeInsets.all(25.0), child: CustomContainer()),

          //text
          Text(
            "Select an image to check the Goru health Status",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Container(
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    top: 12,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xff321254),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Color(0xFFFFFFFF)),
                      SizedBox(width: 8),
                      Text(
                        "Camera",

                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 5),
              TextButton(
                onPressed: () {},
                child: Container(
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    top: 12,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffcc1ad9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFFFFFFFF),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // divider
          Divider(thickness: 2, indent: 20, endIndent: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),

              color: Color(0xff567576),
            ),

            child: Text("About us"),
          ),
        ],
      ),
    );
  }
}
