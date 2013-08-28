require 'debugger'
require './players.rb'
require './board.rb'
require './pieces.rb'
require 'colorize'

class ChessGame

  attr_accessor :board, :turn, :players

  def initialize
    @board = Board.new
    @turn = :white
    @players = {white: HumanPlayer.new(:white), black: HumanPlayer.new(:black)}
  end

  def play
    # get moves and make moves until game is won
    until board.won?(turn) || board.draw?(turn)
      board.render(turn)
      move = players[turn].get_move(board, turn)
      board.make_move(move)
      switch_turn
    end
  end

  def switch_turn
    self.turn = turn == :white ? :black : :white
  end
end

if __FILE__ == $0
  c = ChessGame.new
  c.play
end
