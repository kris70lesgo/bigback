import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:game/screen/loginbutton.dart'; // Your custom button

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In / Sign Up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                width: 300,
                child: Lottie.asset(
                  'assets/animations/Login.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.animation, size: 80, color: Colors.white54),
                          SizedBox(height: 16),
                          Text(
                            'Animation not found',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  print('Continue pressed');
                  // Navigate to actual auth screen or home screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
