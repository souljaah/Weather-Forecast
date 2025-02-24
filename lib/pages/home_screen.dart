import 'package:flutter/material.dart';
import 'home_page.dart';  // Import your weather page

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image covering the entire screen
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/3.webp'),  // Correct image path
                fit: BoxFit.cover,  // Ensure the image covers the whole screen
              ),
            ),
          ),
          // Positioned widget allows us to control where the button is
          Positioned(
            bottom: 150,  // Adjust this value to move the button up or down
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,  // Adjust the width of the button
                height: 50,  // Adjust the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the HomePage (your weather page)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Check Weather'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
