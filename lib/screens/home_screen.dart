import 'package:flutter/material.dart';
import '../components/fancybutton.dart';
import 'multiplayer_game_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock player stats - we'll replace with real data later
  int wins = 0;
  int losses = 0;
  int totalGames = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 30),
              _buildPlayerStats(),
              SizedBox(height: 40),
              _buildGameModes(),
              Spacer(),
              _buildSettingsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.psychology, size: 60, color: Colors.white),
        SizedBox(height: 10),
        Text(
          'Puzzle Duel',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Challenge Your Mind',
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildPlayerStats() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Wins', wins, Colors.green),
              _buildStatItem('Losses', losses, Colors.red),
              _buildStatItem('Games', totalGames, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildGameModes() {
    return Column(
      children: [
        _buildGameModeButton(
          'Practice Mode',
          'Solve puzzles at your own pace',
          Icons.school,
          Colors.blue,
          () => _navigateToPracticeMode(),
        ),
        SizedBox(height: 15),
        _buildGameModeButton(
          'Quick Play',
          'Race against the clock',
          Icons.timer,
          Colors.orange,
          () => _navigateToQuickPlay(),
        ),
        SizedBox(height: 15),
        _buildGameModeButton(
          'Multiplayer',
          'Challenge real players',
          Icons.people,
          Colors.green,
          () => _navigateToMultiplayer(),
        ),
        SizedBox(height: 15),
        _buildGameModeButton(
          'Leaderboard',
          'Coming Soon',
          Icons.leaderboard,
          Colors.grey,
          null, // Disabled for now
          isDisabled: true,
        ),
      ],
    );
  }

  Widget _buildGameModeButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onPressed, {
    bool isDisabled = false,
  }) {
    return Container(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[700] : color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDisabled ? Colors.grey[600]! : color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _showSettings(),
          icon: Icon(Icons.settings, color: Colors.grey[400], size: 24),
        ),
      ],
    );
  }

  void _navigateToPracticeMode() {
    print('Navigate to Practice Mode');
    // TODO: Navigate to practice mode screen
  }

  void _navigateToQuickPlay() {
    print('Navigate to Quick Play');
    // TODO: Navigate to quick play screen
  }

  void _navigateToMultiplayer() {
    print('Navigate to Multiplayer');
    _showPlayerNameDialog();
  }

  void _showPlayerNameDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Enter Your Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MultiplayerGameScreen(
                        playerName: nameController.text.trim(),
                      ),
                    ),
                  );
                }
              },
              child: Text('Start Game', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Settings', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.volume_up, color: Colors.white),
                title: Text('Sound', style: TextStyle(color: Colors.white)),
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.white),
                title: Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Switch(value: false, onChanged: (value) {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
