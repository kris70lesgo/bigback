import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../components/fancybutton.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final String playerName;

  MultiplayerGameScreen({required this.playerName});

  @override
  _MultiplayerGameScreenState createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final GameService _gameService = GameService();

  Map<String, dynamic>? currentGame;
  String? selectedAnswer;
  bool isWaiting = false;
  bool isGameFinished = false;
  String? gameResult;
  String? errorMessage; // Add this to store error messages

  @override
  void initState() {
    super.initState();
    _setupGameService();
    _joinGame();
  }

  void _setupGameService() {
    _gameService.onGameStateChanged = (gameState) {
      setState(() {
        currentGame = gameState;
        isWaiting = false;
        errorMessage = null; // Clear any previous errors
      });
    };

    _gameService.onWaitingForOpponent = (data) {
      setState(() {
        isWaiting = true;
        errorMessage = null; // Clear any previous errors
      });
    };

    _gameService.onGameResult = (result) {
      setState(() {
        isGameFinished = true;
        gameResult =
            result['winnerId'] == _gameService.getCurrentPlayer()?['id']
            ? 'You Won! 🎉'
            : 'You Lost! 😔';
      });
    };

    _gameService.onError = (error) {
      setState(() {
        errorMessage = error; // Store error message
      });
    };

    _gameService.initialize();
  }

  void _joinGame() {
    _gameService.joinGame(widget.playerName);
  }

  void _submitAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
    _gameService.submitAnswer(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Multiplayer Duel'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _gameService.isConnected() ? Icons.wifi : Icons.wifi_off,
            ),
            onPressed: null,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Show error message if there is one
              if (errorMessage != null) _buildErrorMessage(),
              _buildGameHeader(),
              SizedBox(height: 20),
              if (isWaiting) _buildWaitingScreen(),
              if (currentGame != null && !isWaiting) _buildGameScreen(),
              if (isGameFinished) _buildResultScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'You vs ${currentGame?['player2']?['name'] ?? 'Opponent'}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentGame != null)
            Text(
              '${currentGame!['timeRemaining']}s',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'Looking for an opponent...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final puzzle = currentGame!['currentPuzzle'];

    return Expanded(
      child: Column(
        children: [
          // Puzzle Question
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Question',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  puzzle['question'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Answer Options
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 2.5,
              ),
              itemCount: puzzle['options'].length,
              itemBuilder: (context, index) {
                final option = puzzle['options'][index];
                final isSelected = selectedAnswer == option;

                return GestureDetector(
                  onTap: () => _submitAnswer(option),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[700]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gameResult == 'You Won! 🎉'
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
              size: 80,
              color: gameResult == 'You Won! 🎉' ? Colors.yellow : Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              gameResult!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            FancyButton(
              text: 'Play Again',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameService.leaveGame();
    _gameService.disconnect();
    super.dispose();
  }
}
