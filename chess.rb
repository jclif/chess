require_relative 'parser'
require_relative 'board'
require_relative 'players'
require_relative 'pieces'

require 'colorize'
require 'yaml/store'

require 'debugger'; debugger

class ChessGame
  include MoveParser

  attr_accessor :board, :turn, :players, :move_hashes

  def initialize
    @board = Board.new(self)
    @turn = :white
    @players = {white: HumanPlayer.new(:white, self), black: HumanPlayer.new(:black, self)}
    @move_hashes = []
  end

  def play

    until board.draw?
      board.render
      move = players[turn].get_move
      board.make_move(move)
      move_hashes << {piece: board[move[1]], move: move}
      switch_turn
    end

    puts board.won? ? "Congrats!" : "Everybody wins!."
  end

  def switch_turn
    self.turn = turn == :white ? :black : :white
  end

  def self.new_game
    ChessGame.new.play
  end

  def self.load_test_game(test_type)

    game_types = Hash.new
    game_types[:kingside] = ["g2 g3", "g7 g6", "f1 g2", "f8 g7", "g1 f3", "g8 f6"],
    game_types[:queenside] =  ["b2 b3", "b7 b6", "b1 c3", "b8 c6", "c1 b2", "c8 b7", "d2 d3", "d7 d6", "d1 d2", "d8 d7"],
    game_types[:en_pass] = ["d2 d4", "a7 a6", "d4 d5", "e7 e5"]

    if game_types.keys.include?(test_type)
      g = ChessGame.new
      game_types[test_type].each do |input|
        g.board.make_move(g.pgn_to_coords(input))
        g.switch_turn
      end
      g.play
    end
  end
end

if __FILE__ == $0
#  ChessGame.load_test_game(:en_pass)
  ChessGame.new.play
end
