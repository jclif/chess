require 'debugger'; debugger
require './players.rb'
require './board.rb'
require './pieces.rb'

class ChessGame

  attr_accessor :board, :turn, :players

  def initialize
    @board = Board.new
    @turn = :white
    @players = {white: HumanPlayer.new(:white), black: HumanPlayer.new(:black)}
  end

  def play
    # get moves and make moves until game is won
    until board.won? || board.draw?
      board.render(turn)
      move = players[turn].get_move(board, turn)
      make_move(move)
      switch_turn
    end
  end

  def switch_turn
    self.turn = turn == :white ? :black : :white
  end

  def make_move(move) # [[6,0],[5,0]]
    from_row = move[0][0]
    from_col = move[0][1]
    to_row = move[1][0]
    to_col = move[1][1]

    board.board[to_row][to_col] = board.board[from_row][from_col]
    board.board[from_row][from_col] = nil
    board.board[to_row][to_col].pos = move[1]
  end
end

if __FILE__ == $0
  c = ChessGame.new
  c.play
end
