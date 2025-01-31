import SwiftUI

struct GameView: View {
    @ObservedObject var game = Game.shared

    var body: some View {
        VStack {
            Text("Battleship Game")
                .font(.largeTitle)
                .padding()
            
                VStack {
                    Text("Player 1 View")
                        .font(.headline)
                        .padding()
                    GameBoardView(player: .player1)
                }
                
                VStack {
                    Text("Player 2 View")
                        .font(.headline)
                        .padding()
                    EnemyBoardView(player: .bot)
                }
            
            
            if game.gameOver {
                Text("\(game.winner == .player1 ? "Player 1 Wins!" : "Player 2 Wins!")")
                    .font(.headline)
                    .padding()
                
                Button("Reset Game") {
                    game.resetGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("Current Turn: \(game.currentPlayer == .player1 ? "Player 1" : "Player 2")")
                    .padding()
            }
            
            Spacer()
        }
    }
}

struct GameBoardView: View {
    @ObservedObject var game = Game.shared
    var player: Player

    var body: some View {
        GeometryReader{ geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 10
            VStack(spacing: 2) {
                ForEach(0..<10, id: \.self) { x in
                    HStack(spacing: 2) {
                        ForEach(0..<10, id: \.self) { y in
                            CellView(size: cellSize, x: x, y: y, player: player)
                        }
                    }
                }
            }
        }
        .padding()
    }
}


struct EnemyBoardView: View {
    @ObservedObject var game = Game.shared
    var player: Player

    var body: some View {
        GeometryReader{ geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / 10
            VStack(spacing: 2) {
                ForEach(0..<10, id: \.self) { x in
                    HStack(spacing: 2) {
                        ForEach(0..<10, id: \.self) { y in
                            EnemyCellView(size: cellSize, x: x, y: y, player: player)
                            
                        }
                    }
                }
            }
        }
        .padding()
    }
    
}



struct CellView: View {
    var size: CGFloat
    var x: Int
    var y: Int
    var player: Player
    @ObservedObject var game = Game.shared

    var body: some View {
        Rectangle()
            .fill(colorForCell(game.board[x][y], player: player))
            .frame(width: size, height: size)
            .onTapGesture {
                if game.currentPlayer == player {
                    game.makeMove(at: x, y: y)
                    game.makeRandomMove()
                }
                
            }
    }

    private func colorForCell(_ state: CellState, player: Player) -> Color {
        switch state {
        case .empty:
            return Color.blue
        case .ship(let owner):
            if owner == player {
                return player == .player1 ? Color.green : Color.orange
            } else {
                return Color.blue
            }
        case .hit:
            return Color.red
        case .miss:
            return Color.white
        }
    }
}


struct EnemyCellView: View {
    var size: CGFloat
    var x: Int
    var y: Int
    var player: Player
    @ObservedObject var game = Game.shared

    var body: some View {
        Rectangle()
            .fill(colorForCell(game.enemyBoard[x][y], player: player))
            .frame(width: size, height: size)
            .onTapGesture {
                if game.isShipCell(game.enemyBoard[x][y]) || game.enemyBoard[x][y] == .empty {
                    game.makeMove(at: x, y: y)
                    game.makeRandomMove()
                }
            }
            
    }

    private func colorForCell(_ state: CellState, player: Player) -> Color {
        switch state {
        case .empty:
            return Color.blue
        case .ship(let owner):
            if owner == player {
                return player == .bot ? Color.blue : Color.blue
            } else {
                return Color.blue
            }
        case .hit:
            return Color.red
        case .miss:
            return Color.white
        }
    }
}
