import SwiftUI

// MARK: - Models

enum CellState: Equatable {
    case empty
    case ship(Player)
    case hit
    case miss
}

enum Player {
    case player1
    case player2
    case bot
}

struct Ship {
    var size: Int
    var positions: [(x: Int, y: Int)]
    var owner: Player
    
    var isSunk: Bool {
        positions.allSatisfy { Game.shared.board[$0.x][$0.y] == .hit }
    }
}

class Game: ObservableObject {
    static let shared = Game()
    
    @Published var board: [[CellState]]
    @Published var enemyBoard: [[CellState]]
    @Published var currentPlayer: Player
    @Published var gameOver: Bool = false
    @Published var winner: Player?
    
    private var player1Ships: [Ship] = []
    private var player2Ships: [Ship] = []
    
    init() {
        board = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
        enemyBoard = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
        currentPlayer = .player1
        setupShips()
    }
    
    func setupShips() {
        board = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
        enemyBoard = Array(repeating: Array(repeating: .empty, count: 10), count: 10)
        player1Ships = placeShips(for: .player1)
        player2Ships = placeEnemyShips(for: .player2)
    }
    
    private func placeEnemyShips(for player: Player) -> [Ship] {
        let shipSizes = [1, 1, 1, 1, 2, 2, 2, 3, 3, 4]
        var placedShips: [Ship] = []
        
        for size in shipSizes {
            var placed = false
            while !placed {
                let direction = Bool.random() // true for horizontal, false for vertical
                let x = Int.random(in: 0..<(10 - (direction ? size : 0)))
                let y = Int.random(in: 0..<(10 - (direction ? 0 : size)))
                
                let positions = (0..<size).map {
                    (x: x + (direction ? $0 : 0), y: y + (direction ? 0 : $0))
                }
                
                if positions.allSatisfy({ enemyBoard[$0.x][$0.y] == .empty }) {
                    for pos in positions {
                        enemyBoard[pos.x][pos.y] = .ship(player)
                    }
                    let newShip = Ship(size: size, positions: positions, owner: player)
                    placedShips.append(newShip)
                    placed = true
                }
            }
        }
        
        return placedShips
    }
    
    private func placeShips(for player: Player) -> [Ship] {
        let shipSizes = [1, 1, 1, 1, 2, 2, 2, 3, 3, 4]
        var placedShips: [Ship] = []
        
        for size in shipSizes {
            var placed = false
            while !placed {
                let direction = Bool.random() // true for horizontal, false for vertical
                let x = Int.random(in: 0..<(10 - (direction ? size : 0)))
                let y = Int.random(in: 0..<(10 - (direction ? 0 : size)))
                
                let positions = (0..<size).map {
                    (x: x + (direction ? $0 : 0), y: y + (direction ? 0 : $0))
                }
                
                if positions.allSatisfy({ board[$0.x][$0.y] == .empty }) {
                    for pos in positions {
                        board[pos.x][pos.y] = .ship(player)
                    }
                    let newShip = Ship(size: size, positions: positions, owner: player)
                    placedShips.append(newShip)
                    placed = true
                }
            }
        }
        
        return placedShips
    }
    
    func makeMove(at x: Int, y: Int) {
        guard !gameOver, enemyBoard[x][y] == .miss || enemyBoard[x][y] == .empty || isShipCell(enemyBoard[x][y]) else { return }
        
        if isShipCell(enemyBoard[x][y]) {
            enemyBoard[x][y] = .hit
        } else {
            enemyBoard[x][y] = .miss
        }
        
        checkWinCondition()
        
        if !gameOver {
            switchTurn()
        }
    }
    
    func makeRandomMove() {
        var x = Int.random(in: 0..<10)
        var y = Int.random(in: 0..<10)
        while (board[x][y] == .hit || board[x][y] == .miss) { x=Int.random(in: 0..<10); y=Int.random(in: 0..<10) }
        guard !gameOver, board[x][y] == .empty || isShipCell(board[x][y]) else { print(board[x][y]); return }
        if isShipCell(board[x][y]) {
            board[x][y] = .hit
        } else {
            board[x][y] = .miss
        }
        
        checkWinCondition()
        
        if !gameOver {
            switchTurn()
        }
    }
    
    public func isShipCell(_ state: CellState) -> Bool {
        if case .ship = state {
            return true
        }
        return false
    }
    
    private func switchTurn() {
        currentPlayer = (currentPlayer == .player1) ? .player2 : .player1
    }
    
    private func checkWinCondition() {
        if player1Ships.allSatisfy({ $0.positions.allSatisfy { Game.shared.board[$0.x][$0.y] == .hit } }) {
            gameOver = true
            winner = .player2
        }
        else if player2Ships.allSatisfy({ $0.positions.allSatisfy { Game.shared.enemyBoard[$0.x][$0.y] == .hit } }) {
            gameOver = true
            winner = .player1
        }
    }
    
    func resetGame() {
        gameOver = false
        winner = nil
        currentPlayer = .player1
        setupShips()
    }
}
