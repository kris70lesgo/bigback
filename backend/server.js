const express = require("express");
const http = require("http");
const socketIo = require("socket.io");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// Middleware
app.use(cors());
app.use(express.json());

// Game state storage (in-memory for MVP)
const waitingPlayers = [];
const activeGames = new Map();
const playerStats = new Map();

// Sample puzzles for MVP
const puzzles = [
  {
    id: "1",
    question: "What is 15 + 27?",
    correctAnswer: "42",
    options: ["40", "41", "42", "43"],
    timeLimit: 30,
  },
  {
    id: "2",
    question: "If you have 8 apples and eat 3, how many do you have left?",
    correctAnswer: "5",
    options: ["3", "4", "5", "6"],
    timeLimit: 30,
  },
  {
    id: "3",
    question: "What is 7 × 6?",
    correctAnswer: "42",
    options: ["36", "42", "48", "54"],
    timeLimit: 30,
  },
  {
    id: "4",
    question: "Which number comes next: 2, 4, 6, 8, __?",
    correctAnswer: "10",
    options: ["9", "10", "11", "12"],
    timeLimit: 30,
  },
  {
    id: "5",
    question: "What is half of 26?",
    correctAnswer: "13",
    options: ["12", "13", "14", "15"],
    timeLimit: 30,
  },
];

// Helper functions
function getRandomPuzzle() {
  const randomIndex = Math.floor(Math.random() * puzzles.length);
  return puzzles[randomIndex];
}

function findMatch(player) {
  if (waitingPlayers.length > 0) {
    const opponent = waitingPlayers.shift();
    return opponent;
  }
  return null;
}

function createGame(player1, player2) {
  const gameId = uuidv4();
  const puzzle = getRandomPuzzle();

  const game = {
    id: gameId,
    player1: player1,
    player2: player2,
    puzzle: puzzle,
    answers: {},
    startTime: Date.now(),
    status: "waiting",
  };

  activeGames.set(gameId, game);
  return game;
}

function determineWinner(game) {
  const player1Answer = game.answers[game.player1.id];
  const player2Answer = game.answers[game.player2.id];

  const player1Correct =
    player1Answer && player1Answer.answer === game.puzzle.correctAnswer;
  const player2Correct =
    player2Answer && player2Answer.answer === game.puzzle.correctAnswer;

  if (player1Correct && !player2Correct) return game.player1.id;
  if (player2Correct && !player1Correct) return game.player2.id;
  if (player1Correct && player2Correct) {
    // Both correct, faster wins
    const player1Time = player1Answer.time - game.startTime;
    const player2Time = player2Answer.time - game.startTime;
    return player1Time < player2Time ? game.player1.id : game.player2.id;
  }
  return null; // No winner
}

// Socket.IO event handlers
io.on("connection", (socket) => {
  console.log("Player connected:", socket.id);

  // Player joins the game
  socket.on("joinGame", (data) => {
    const player = {
      id: data.player.id,
      name: data.player.name,
      socketId: socket.id,
    };

    console.log("Player joining:", player.name);

    // Check if there's a waiting opponent
    const opponent = findMatch(player);

    if (opponent) {
      // Create a game with the opponent
      const game = createGame(opponent, player);

      // Join both players to the game room
      socket.join(game.id);
      io.sockets.sockets.get(opponent.socketId)?.join(game.id);

      // Send game state to both players
      const gameState = {
        gameId: game.id,
        player1: game.player1,
        player2: game.player2,
        currentPuzzle: game.puzzle,
        status: "playing",
        timeRemaining: game.puzzle.timeLimit,
        answers: game.answers,
      };

      io.to(game.id).emit("gameState", gameState);
      console.log(
        "Game created:",
        game.id,
        "between",
        game.player1.name,
        "and",
        game.player2.name
      );
    } else {
      // Add player to waiting queue
      waitingPlayers.push(player);
      socket.emit("waitingForOpponent", {
        message: "Looking for an opponent...",
      });
      console.log("Player waiting:", player.name);
    }
  });

  // Player submits an answer
  socket.on("submitAnswer", (data) => {
    const game = activeGames.get(data.gameId);
    if (!game) return;

    const answer = {
      answer: data.answer,
      time: Date.now(),
    };

    game.answers[data.playerId] = answer;

    // Check if both players have answered
    if (Object.keys(game.answers).length === 2) {
      const winnerId = determineWinner(game);
      game.status = "finished";
      game.winnerId = winnerId;

      // Update player stats
      if (winnerId) {
        const winner =
          winnerId === game.player1.id ? game.player1 : game.player2;
        const loser =
          winnerId === game.player1.id ? game.player2 : game.player1;

        // Update stats (in-memory for now)
        playerStats.set(winner.id, {
          wins: (playerStats.get(winner.id)?.wins || 0) + 1,
          losses: playerStats.get(winner.id)?.losses || 0,
          totalGames: (playerStats.get(winner.id)?.totalGames || 0) + 1,
        });

        playerStats.set(loser.id, {
          wins: playerStats.get(loser.id)?.wins || 0,
          losses: (playerStats.get(loser.id)?.losses || 0) + 1,
          totalGames: (playerStats.get(loser.id)?.totalGames || 0) + 1,
        });
      }

      // Send game result to both players
      const gameResult = {
        gameId: game.id,
        winnerId: winnerId,
        answers: game.answers,
        puzzle: game.puzzle,
      };

      io.to(game.id).emit("gameResult", gameResult);

      // Clean up game after a delay
      setTimeout(() => {
        activeGames.delete(game.id);
      }, 5000);
    } else {
      // Send updated game state
      const gameState = {
        gameId: game.id,
        player1: game.player1,
        player2: game.player2,
        currentPuzzle: game.puzzle,
        status: "playing",
        timeRemaining: game.puzzle.timeLimit,
        answers: game.answers,
      };

      io.to(game.id).emit("gameState", gameState);
    }
  });

  // Player leaves the game
  socket.on("leaveGame", (data) => {
    // Remove from waiting queue if they were waiting
    const waitingIndex = waitingPlayers.findIndex(
      (p) => p.id === data.playerId
    );
    if (waitingIndex !== -1) {
      waitingPlayers.splice(waitingIndex, 1);
    }

    // Leave game room
    socket.leaveAll();
    console.log("Player left:", data.playerId);
  });

  // Player disconnects
  socket.on("disconnect", () => {
    console.log("Player disconnected:", socket.id);

    // Remove from waiting queue
    const waitingIndex = waitingPlayers.findIndex(
      (p) => p.socketId === socket.id
    );
    if (waitingIndex !== -1) {
      waitingPlayers.splice(waitingIndex, 1);
    }
  });
});

// API endpoints
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    activeGames: activeGames.size,
    waitingPlayers: waitingPlayers.length,
  });
});

app.get("/api/stats/:playerId", (req, res) => {
  const stats = playerStats.get(req.params.playerId) || {
    wins: 0,
    losses: 0,
    totalGames: 0,
  };
  res.json(stats);
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Puzzle Duel Server running on port ${PORT}`);
  console.log(`📊 Active games: ${activeGames.size}`);
  console.log(`⏳ Waiting players: ${waitingPlayers.length}`);
});
