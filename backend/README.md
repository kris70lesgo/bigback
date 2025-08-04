# Puzzle Duel Backend Server

Real-time multiplayer backend for the Puzzle Duel game.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Start the Server

```bash
# Development mode (auto-restart on changes)
npm run dev

# Production mode
npm start
```

### 3. Test the Server

The server will run on `http://localhost:3000`

Check if it's working:

```bash
curl http://localhost:3000/api/health
```

## 📡 API Endpoints

### Health Check

- `GET /api/health` - Server status and game statistics

### Player Stats

- `GET /api/stats/:playerId` - Get player win/loss statistics

## 🎮 Socket.IO Events

### Client → Server

- `joinGame` - Player wants to join a game
- `submitAnswer` - Player submits their answer
- `leaveGame` - Player leaves the current game

### Server → Client

- `waitingForOpponent` - Player is waiting for match
- `gameState` - Current game state update
- `gameResult` - Game finished with results

## 🏗️ Architecture

### Game Flow

1. **Player Joins** → Added to waiting queue
2. **Match Found** → Two players paired, game created
3. **Puzzle Sent** → Same puzzle sent to both players
4. **Answers Received** → Both players submit answers
5. **Winner Determined** → Fastest correct answer wins
6. **Results Sent** → Winner/loser announced

### Data Storage

- **In-Memory** (for MVP)
  - `waitingPlayers` - Queue of players looking for games
  - `activeGames` - Currently running games
  - `playerStats` - Win/loss statistics

## 🔧 Configuration

### Environment Variables

- `PORT` - Server port (default: 3000)

### Sample Puzzles

Currently includes 5 math/logic puzzles. Easy to add more in `server.js`.

## 🧪 Testing

### Manual Testing

1. Start the server
2. Use a WebSocket client (like Postman) to connect
3. Send `joinGame` event with player data
4. Test with two clients to simulate a game

### Example Client Connection

```javascript
const socket = io("http://localhost:3000");

socket.emit("joinGame", {
  player: {
    id: "player1",
    name: "Alice",
  },
});

socket.on("gameState", (data) => {
  console.log("Game state:", data);
});
```

## 📊 Monitoring

The server logs:

- Player connections/disconnections
- Game creation and completion
- Waiting queue status
- Active game count

## 🚀 Next Steps

### For Production

- Add database (MongoDB/PostgreSQL)
- Add authentication
- Add rate limiting
- Add error handling
- Add logging
- Add tests

### For Development

- Add more puzzles
- Add different game modes
- Add player rankings
- Add chat functionality
