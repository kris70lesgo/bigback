import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

class GameService {
  // Socket connection for real-time communication
  IO.Socket? socket;

  // Current game state
  Map<String, dynamic>? currentGame;

  // Current player
  Map<String, dynamic>? currentPlayer;

  // Callbacks for UI updates
  Function(Map<String, dynamic>)? onGameStateChanged;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(Map<String, dynamic>)? onWaitingForOpponent;
  Function(Map<String, dynamic>)? onGameResult;

  // Timer for countdown
  Timer? _timer;

  // Server URL - Use 10.0.2.2 for Android emulator to access host computer
  static const String serverUrl = 'http://10.0.2.2:3000';

  // Initialize the service
  void initialize() {
    _connectToServer();
  }

  // Connect to the game server
  void _connectToServer() {
    try {
      print('Attempting to connect to: $serverUrl');
      socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'timeout': 5000, // 5 second timeout
      });

      _setupSocketListeners();
    } catch (e) {
      print('Connection error: $e');
      onError?.call('Failed to connect to server: $e');
    }
  }

  // Set up socket event listeners
  void _setupSocketListeners() {
    socket?.onConnect((_) {
      print('Connected to server');
      onConnected?.call();
    });

    socket?.onDisconnect((_) {
      print('Disconnected from server');
      onDisconnected?.call();
    });

    socket?.on('gameState', (data) {
      print('Game state received: $data');
      currentGame = data;
      onGameStateChanged?.call(data);
    });

    socket?.on('waitingForOpponent', (data) {
      print('Waiting for opponent: $data');
      onWaitingForOpponent?.call(data);
    });

    socket?.on('gameResult', (data) {
      print('Game result received: $data');
      onGameResult?.call(data);
    });

    socket?.on('error', (data) {
      onError?.call(data.toString());
    });
  }

  // Join the game as a player
  void joinGame(String playerName) {
    if (socket == null || !socket!.connected) {
      onError?.call('Not connected to server');
      return;
    }

    // Create a new player
    currentPlayer = {'id': Uuid().v4(), 'name': playerName};

    // Send join request to server
    socket?.emit('joinGame', {'player': currentPlayer});

    print('Joining game as: $playerName');
  }

  // Submit an answer
  void submitAnswer(String answer) {
    if (socket == null || currentPlayer == null || currentGame == null) {
      onError?.call('Cannot submit answer');
      return;
    }

    socket?.emit('submitAnswer', {
      'gameId': currentGame!['gameId'],
      'playerId': currentPlayer!['id'],
      'answer': answer,
    });

    print('Submitted answer: $answer');
  }

  // Leave the current game
  void leaveGame() {
    if (socket == null) return;

    socket?.emit('leaveGame', {
      'gameId': currentGame?['gameId'],
      'playerId': currentPlayer?['id'],
    });

    _stopTimer();
    currentGame = null;
  }

  // Disconnect from server
  void disconnect() {
    _stopTimer();
    socket?.disconnect();
    socket = null;
    currentGame = null;
    currentPlayer = null;
  }

  // Start the countdown timer
  void _startTimer() {
    _stopTimer(); // Stop any existing timer

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentGame != null && currentGame!['timeRemaining'] > 0) {
        currentGame!['timeRemaining'] = currentGame!['timeRemaining'] - 1;
        onGameStateChanged?.call(currentGame!);
      } else {
        _stopTimer();
      }
    });
  }

  // Stop the countdown timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // Get current player
  Map<String, dynamic>? getCurrentPlayer() => currentPlayer;

  // Get current game
  Map<String, dynamic>? getCurrentGame() => currentGame;

  // Check if connected to server
  bool isConnected() => socket?.connected ?? false;
}
