import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:game/components/fancybutton.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController _pageController = PageController();
  int currentPage = 0;

  // Updated slide content data with local animation files
  final List<Map<String, String>> slideData = [
    {
      'title': 'Challenge Players Worldwide',
      'description': 'Compete in real-time brain duels with players from around the globe. Test your skills and climb the leaderboard!',
      'animation': 'assets/animations/Battle.json'  // Changed to local file
    },
    {
      'title': 'Fast-Paced Brain Training',
      'description': 'Quick thinking wins! Solve puzzles faster than your opponent to claim victory in exciting duels.',
      'animation': 'assets/animations/First Place.json'  // Changed to local file
    },
    {
      'title': 'Climb the Leaderboard',
      'description': 'Track your progress, earn achievements, and become the ultimate brain champion among millions.',
      'animation': 'assets/animations/level up.json'  // Changed to local file
    },
    {
      'title': 'Ready to Play?',
      'description': 'Jump in instantly as a guest or create an account to save your progress and compete with friends.',
      'animation': 'assets/animations/Girl tapping phone.json'  // Changed to local file
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildPageIndicator(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                itemCount: slideData.length,
                itemBuilder: (context, index) {
                  return _buildSlide(index);
                },
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(slideData.length, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: currentPage == index ? 12 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: currentPage == index ? Colors.white : Colors.grey[600],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlide(int index) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Updated Lottie Animation container to use local assets
          Container(
            height: 300,
            width: 300,
            child: Lottie.asset(  // Changed from Lottie.network to Lottie.asset
              slideData[index]['animation']!,
              repeat: true,
              animate: true,
              fit: BoxFit.contain,
              // Added error handling for better stability
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
                      Icon(
                        Icons.animation,
                        size: 80,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Animation not found',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 40),

          Text(
            slideData[index]['title']!,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          Text(
            slideData[index]['description']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentPage > 0)
            FancyButton(
              text: 'Previous',
              onPressed: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          else
            SizedBox(width: 100),

          FancyButton(
            text: currentPage < slideData.length - 1 ? 'Next' : 'Get Started',
            onPressed: () {
              if (currentPage < slideData.length - 1) {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // Show login animation before navigating
                _showLoginAnimation();
              }
            },
          ),
        ],
      ),
    );
  }

  // New method to show login animation
  void _showLoginAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 400,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/animations/login.json',  // Login animation
                    repeat: false,
                    animate: true,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      // Auto-close after animation completes
                      Future.delayed(composition.duration, () {
                        Navigator.of(context).pop();
                        print('Navigate to Login/Guest Screen');
                        // Add your navigation logic here
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
