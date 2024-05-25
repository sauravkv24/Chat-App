import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MinesweeperGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper Game',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 5;
  static const int mineCount = 3;

  late List<List<Cell>> grid;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    grid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        return Cell(row: row, col: col);
      });
    });
    _placeMines();
    gameOver = false;
  }

  void _placeMines() {
    Random random = Random();
    int minesPlaced = 0;

    while (minesPlaced < mineCount) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize);

      if (!grid[row][col].isMine) {
        grid[row][col].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _revealCell(int row, int col) {
    if (gameOver || grid[row][col].revealed) return;

    setState(() {
      grid[row][col].revealed = true;
      if (grid[row][col].isMine) {
        gameOver = true;
        _showGameOverDialog();
      } else {
        int adjacentMines = _countAdjacentMines(row, col);
        grid[row][col].adjacentMines = adjacentMines;
      }
    });
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    List<int> directions = [-1, 0, 1];

    for (int dRow in directions) {
      for (int dCol in directions) {
        int newRow = row + dRow;
        int newCol = col + dCol;

        if (newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize) {
          if (grid[newRow][newCol].isMine) {
            count++;
          }
        }
      }
    }

    return count;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("You hit a mine!"),
          actions: [
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemBuilder: (context, index) {
        int row = index ~/ gridSize;
        int col = index % gridSize;
        return GestureDetector(
          onTap: () => _revealCell(row, col),
          child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: grid[row][col].revealed
                    ? (grid[row][col].isMine ? Colors.red : Colors.white)
                    : Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  grid[row][col].revealed
                      ? (grid[row][col].isMine ? "M" : (grid[row][col].adjacentMines > 0 ? "${grid[row][col].adjacentMines}" : ""))
                      : "",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: gridSize * gridSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minesweeper'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: _buildGrid(),
          ),
        ),
      ),
    );
  }
}

class Cell {
  final int row;
  final int col;
  bool isMine;
  bool revealed;
  int adjacentMines;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.revealed = false,
    this.adjacentMines = 0,
  });
}