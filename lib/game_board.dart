import 'package:chess_king/components/dead_piece.dart';
import 'package:chess_king/components/piece.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'components/square.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  
  // a 2-d  list representing the chessboard
  // with each position possibly containing a chesspiece

  late List<List<ChessPiece?>> board;

// currently selected piece
ChessPiece ? selectedPiece;

// the row index of the selected piece
int selectedRow=-1;
int selectedCol =-1;

// a list of valid moves for the currently selected piece

       // each move is represented as a list with 2 elements:row & col
       
List<List<int>> validMoves =[];

List<ChessPiece> whitePieceTaken = [];

List<ChessPiece> blackPieceTaken = [];

// turn of the players

bool isWhiteTurn = true;

// initial position of king

List<int> whiteKingPosition =[7,3];
List<int> blackKingPosition=[0,4];

bool checkStatus = false;
@override
void initState(){
  super.initState();
  _initializeBoard();
}
  // INITIALISE THE BOARD

  void _initializeBoard(){

List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8,(index) => null));
 

// newBoard[3][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'lib/images/queen.png');

 // Place pawns
 for(int i=0;i<8;i++){
  newBoard[1][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'lib/images/pawn.png');
   newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'lib/images/pawn.png');
 }
 // Place rooks
 newBoard[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/rook.png');
 newBoard[0][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'lib/images/rook.png');
 newBoard[7][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/rook.png');
 newBoard[7][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'lib/images/rook.png');
 // Place knights
newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/knight.png');
 newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'lib/images/knight.png');
 newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/knight.png');
 newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'lib/images/knight.png');

 // Place bishops

newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/bishop.png');
 newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'lib/images/bishop.png');
 newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/bishop.png');
 newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'lib/images/bishop.png');

 // Place King
newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: 'lib/images/king.png');
 newBoard[7][3] = ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: 'lib/images/king.png');
 
 // Place Queen
 newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'lib/images/queen.png');
 newBoard[7][4] = ChessPiece(type: ChessPieceType.queen, isWhite: true, imagePath: 'lib/images/queen.png');
 
 board = newBoard;
  }
  
 
 void pieceSelected(int row , int col){
setState(() {

  if(selectedPiece == null && board[row][col] !=null){
    if(board[row][col]!.isWhite == isWhiteTurn ){
       selectedPiece = board[row][col];
    selectedCol=col;
    selectedRow=row;
    }
  }
  // selected a piece if there is a piece in that position

 else if (board[row][col]!=null && board[row][col]!.isWhite == selectedPiece!.isWhite){
    selectedPiece = board[row][col];
    selectedCol=col;
    selectedRow=row;
  }

// if there is a piece selected and user tap to square which is valid

else if(selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col )){

movePiece(row, col);
}
  // if piece is selected

  validMoves = calculatedRealValidMoves(selectedRow,selectedCol,selectedPiece,true);
});
 }

 // CALCULATE RAW VALID MOVES

 List<List<int>> calculateRawValidMoves(int row, int col , ChessPiece? piece){

List<List<int>> candidateMoves =[];


if(piece == null){
  return [];
}
// different directions based on their color

int direction = piece.isWhite ? -1 : 1;

switch (piece.type){
  case ChessPieceType.pawn:
  // it can move forward if it does not occupy
   if (isInBoard(row + direction, col) && board[row + direction][col]==null){
    candidateMoves.add([row+direction,col]);
   }
  

  // it can move 2 square initially
   if((row ==1 && !piece.isWhite)||(row==6 && piece.isWhite)){
     if(isInBoard(row+2*direction, col) && board[row+2*direction][col]==null && board[row +direction][col]==null){
      candidateMoves.add([row+2*direction,col]);
     }
   }
  // it can kill diagonally

  if(isInBoard(row+ direction, col-1) && board[row+ direction][col-1]!=null  && board[row+ direction][col-1]!.isWhite != piece.isWhite){
       candidateMoves.add([row+direction, col-1]);
  }

  if(isInBoard(row+ direction, col+1) && board[row+ direction][col+1]!=null  && board[row+ direction][col+1]!.isWhite != piece.isWhite){
       candidateMoves.add([row+direction, col+1]);
  }
  break;
  case ChessPieceType.rook:

  // it can move vertical and horizontal

  var directions = [ 
    [-1,0], //up
    [1,0],// down
    [0,-1], //left
    [0,1], // right
  ];
  for(var direction in directions){
    var i=1;
    while(true){
   var newRow = row + i*direction[0];
   var newCol = col  +i*direction[1];

   if(!isInBoard(newRow, newCol)){
    break;
   }
   if(board[newRow][newCol]!=null){
    if(board[newRow][newCol]!.isWhite !=piece.isWhite){
      candidateMoves.add([newRow,newCol]); //kill
    }
    break; // blocked
   }
   candidateMoves.add([newRow,newCol]);
   i++;
    }
  }

  break;
  case ChessPieceType.knight:

  var knightMoves =[
  [-2,-1], // up 2 left 1
  [-2,1], // up 2 right 1
  [-1,-2], // up 1 left 2
  [-1,2],// up 1 right 2
  [1,-2], // down1 left 2
  [1,2] ,// down 1 right 2
  [2,-1], // down 2 left 1
  [2,1], // down 2 right 1
  ];

  for(var move in knightMoves){
    var newRow = row +move[0];
    var newCol = col + move[1];
    if(!isInBoard(newRow, newCol)){
      continue;
    }
    if(board[newRow][newCol]!=null){
      if(board[newRow][newCol]!.isWhite != piece.isWhite){
        candidateMoves.add([newRow,newCol]);
      }
      continue;
    }
    candidateMoves.add([newRow,newCol]);
  }
  break;
  case ChessPieceType.bishop:
  // moves diagonally

  var directions =[
  [-1,-1], // up left
  [-1,1], // up right
  [1,-1], // down left
  [1,1], // down right
  ];

  for(var direction in directions){
    var i=1;
    while(true){
      var newRow = row +i*direction[0];
      var newCol=col +i*direction[1];
      if(!isInBoard(newRow, newCol)){
        break;
      }
      if(board[newRow][newCol]!=null){
        if(board[newRow][newCol]!.isWhite != piece.isWhite){
          candidateMoves.add([newRow,newCol]);
        }
        break;
      }
      candidateMoves.add([newRow, newCol]);
      i++;
    }

  }
  break;
  case ChessPieceType.queen:
  // all eight directions : up, down ,left ,right and 4 diagonals

  var directions = [
    [-1,0],//up
    [1,0],// down
    [0,-1],// left
    [0,1],// right
    [-1,-1],// up left
    [-1,1],// up right
    [1,-1],// down left
    [1,1],// down right
  ];

  for(var direction in directions){
    var i=1;
    while(true){
      var newRow = row +i*direction[0];
      var newCol = col +i*direction[1];
      if(!isInBoard(newRow,newCol)){
        break;
      }
      if(board[newRow][newCol]!= null){
        if(board[newRow][newCol]!.isWhite != piece.isWhite){
          candidateMoves.add([newRow,newCol]);
        }
        break;
      }
      candidateMoves.add([newRow,newCol]);
      i++;
    }
  }
  break;
  case ChessPieceType.king:
  var directions = [
    [-1,0],//up
    [1,0],// down
    [0,-1],// left
    [0,1],// right
    [-1,-1],// up left
    [-1,1],// up right
    [1,-1],// down left
    [1,1],// down right
  ];

  for(var direction in directions){
    var newRow = row + direction[0];
    var newCol= col + direction[1];
    if(!isInBoard(newRow, newCol)){
      continue;
    }
    if(board[newRow][newCol ]!=null){
      if(board[newRow][newCol]!.isWhite != piece.isWhite){
        candidateMoves.add([newRow,newCol]);
      }
      continue;
    }
    candidateMoves.add([newRow,newCol]);
  }
  break;
}
return candidateMoves;
 }
  
 
 List<List<int>> calculatedRealValidMoves(int row , int col , ChessPiece? piece ,bool checkSimulation){

List<List<int>> realValidMoves =[];
List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

// after generating all candidate move , filter move which result in check

if(checkSimulation){
  for(var move in candidateMoves ){
    int endRow = move[0];
    int endCol =move[1];
    if(simulatedMoveIsSafe(piece! , row , col,endRow,endCol)){
      realValidMoves.add(move);
    }
   
  }
}
else{
  realValidMoves = candidateMoves;
}
return realValidMoves;
 }
  // MOVE PIECE

  void movePiece(int newRow , int newCol){
    
    // if the new spot has enemy piece
    if(board[newRow][newCol] != null){

      var capturedPiece = board[newRow][newCol];
      if(capturedPiece!.isWhite){
        whitePieceTaken.add(capturedPiece);
      }
      else{
        blackPieceTaken.add(capturedPiece);
      }
    }
    // check if the piece moved in a king

    if(selectedPiece!.type == ChessPieceType.king){
      if(selectedPiece!.isWhite){
      whiteKingPosition =[newRow,newCol];
    }
    
    else{
      blackKingPosition = [newRow,newCol];
    }
    
    }
    // move the piece and clear the old spot
 
  board[newRow][newCol] = selectedPiece;
  board[selectedRow][selectedCol] = null;


// see if any king are under attack

if(isKingInCheck(!isWhiteTurn)){
  checkStatus =true;
}
else{
  checkStatus =false;
}

    // clear selection

    setState(() {
      selectedPiece=null;
      selectedCol=-1;
      selectedRow=-1;
      validMoves=[];
    });

// check if it is check mate

if(isCheckMate(!isWhiteTurn)){
  showDialog(
    context: context,
     builder: (context) =>
     AlertDialog(
      title: const Text("CHECK MATE!"),
      actions: [
        TextButton(onPressed: resetGame,
         child: const Text("Play Again")),
      ],
     ));
}

    // change turns
isWhiteTurn = !isWhiteTurn;
  }
  
  bool isKingInCheck(bool isWhiteKing){

    // get the position of king\
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

for(int i=0;i<8;i++){
  for(int j=0;j<8;j++){
    if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
      continue;

    }
    List<List<int>> pieceValidMoves = calculatedRealValidMoves(i, j, board[i][j],false);

// check if the king position is in valid moves

if( pieceValidMoves.any((move)=>move[0] == kingPosition[0]  && move[1]==kingPosition[1])){
  return true;
}

  }
}
return false;
  }
  
  bool simulatedMoveIsSafe(ChessPiece piece , int startRow , int startCol , int endRow,int endCol ){

// save the current board state

ChessPiece? originalDestinationPiece = board[endRow][endCol];
// if the piece is the king , save it's current position and update to the new one

List<int>? originalKingPosition;
if(piece.type == ChessPieceType.king){
  originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition ;

// update the king position

if(piece.isWhite){
  whiteKingPosition = [endRow,endCol];
}
else{
  blackKingPosition =[endRow,endCol];
}
}
// simulate the move

board[endRow][endCol] =piece;
board[startRow][startCol] =null;
// check if our own king is under attack

bool kingInCheck = isKingInCheck(piece.isWhite);
// restore board to original state

board[startRow][startCol] = piece;
board[endRow][endCol]= originalDestinationPiece;
// if the piece was teh king , restore its original position

if(piece.type == ChessPieceType.king){
  if(piece.isWhite){
    whiteKingPosition = originalKingPosition!;
  }
  else{
    blackKingPosition = originalKingPosition!;
  }
}
return !kingInCheck;
  }
 
 bool isCheckMate(bool isWhiteKing){
  // if the king is not in check , then it's not checkmate
 
 if(!isKingInCheck(isWhiteKing)){
  return false;
 }
  // if there is at least one legal move for any of the players pieces , then its not the checkmate

for(int i=0;i<8;i++){
  for(int j=0;j<8;j++){
    //skip empty squares and pieces of the other color

    if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing){
      continue;
    }
    List<List<int>> pieceValidMoves = calculatedRealValidMoves(i, j, board[i][j], true);
  
  // if this piece has any valid moves , thrn its not the checkmate

  if(pieceValidMoves.isNotEmpty){
    return false;
  }
  }
}
  // if none of the above conditions that there is no legal move then its checkmate

return true;
 }

// reset the game

void resetGame(){
  Navigator.pop(context);
  _initializeBoard();
  checkStatus = false;
  whitePieceTaken.clear();
  blackPieceTaken.clear();
  whiteKingPosition =[7,4];
  blackKingPosition =[0,4];
  isWhiteTurn =true;
  setState(() {
    
  });
}
 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      // backgroundColor: Color.fromARGB(255, 62, 36, 36) ,
      title: Center(
        child:  Text('♛ Chess ♛',
        style: GoogleFonts.robotoMono( 
          fontSize: 30,
          color: Colors.white,
          
        ),),
      ),
        flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color.fromARGB(255, 238, 238, 0), Colors.brown]),
      ),
    ),
      ),
      backgroundColor: const Color.fromRGBO(45, 70, 72, 1),
      body: Column(         
            children: [
              const SizedBox(
                height: 40,
              ),
              const Text("Player 1",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              // white pieces taken
          Expanded(
            child: GridView.builder(
              physics:  const NeverScrollableScrollPhysics(),
              itemCount: whitePieceTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: ((context, index) {
             return   DeadPiece(
                  imagePath: whitePieceTaken[index].imagePath,
                  isWhite: true,
                );
              })
              )
            ),
          
            // game status
            Text(checkStatus ?"CHECK!":""),
              // chess board
              Expanded(
                flex: 5,
                child: GridView.builder(
                  itemCount: 8*8,
                  physics:const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8, ), 
                itemBuilder:(context,index){
                 int row = index~/8;
                 int col = index%8;
              
                 // check square is selected or not
              
                 bool isSelected = selectedCol==col && selectedRow==row;
              
              // check if it is valid move 
                 bool isValidMove=false;
                  for(var position in validMoves){
                 // compare the row and col
              
                 if(position[0]==row && position[1]==col){
                  isValidMove=true;
                 }
              }
                  return Square(
                    onTap: ()=> pieceSelected(row, col),
                    isSelected: isSelected,
                    isWhite: isWhite(index),
                    isValidMove: isValidMove,
                    piece:board[row][col],);
                }
                  ),
              ),
          
            // black piece taken
          
             Expanded(
              child: GridView.builder(
              physics:const  NeverScrollableScrollPhysics(),
              itemCount: blackPieceTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), 
              itemBuilder: ((context, index) {
              return  DeadPiece(
                  imagePath: blackPieceTaken[index].imagePath,
                  isWhite: false,
                );
              })
              )
            ),
              const Text("Player 2",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
    );
  }
}