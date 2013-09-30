require_relative 'parser'
require_relative 'board'
require_relative 'players'
require_relative 'pieces'

require 'colorize'
require 'yaml/store'

require 'debugger'; debugger

class ChessGame
  include MoveParser

  attr_accessor :board, :turn, :players, :move_hashes, :moving

  def initialize
    @board = Board.new(self)
    @turn = :white
    @players = {white: HumanPlayer.new(:white, self), black: HumanPlayer.new(:black, self)}
    @move_hashes = []
    @moving = false # dirty hack for making sure when you check a move to see
    # if the resulting position from a pawn promotion move doesnt' leave you in check,
    # you don't prompt user for what piece they want to upgrade (because if won't matter)
  end

  def play

    until board.draw?
      board.render
      debugger
      move = players[turn].get_move
      self.moving = true
      board.make_move(move)
      self.moving = false
      move_hashes << {piece: board[move[1]], move: move}
      switch_turn
    end

    if board.won?
      switch_turn
      puts "#{turn.to_s.capitalize} wins!"
    else
      puts "Everybody wins!."
    end
  end

  def switch_turn
    self.turn = turn == :white ? :black : :white
  end

  def self.new_game
    ChessGame.new.play
  end

  # this should be moved to rpsec
  def self.load_test_game(test_type)

    game_types = Hash.new
    game_types[:kingside] = ["g2 g3", "g7 g6", "f1 g2", "f8 g7", "g1 f3", "g8 f6"]
    game_types[:queenside] =  ["b2 b3", "b7 b6", "b1 c3", "b8 c6", "c1 b2", "c8 b7", "d2 d3", "d7 d6", "d1 d2", "d8 d7"]
    game_types[:white_en_pass_right] = ["d2 d4", "a7 a6", "d4 d5", "e7 e5"]
    game_types[:white_en_pass_left] = ["d2 d4", "a7 a6", "d4 d5", "c7 c5"]
    game_types[:fools_mate] = ["f2 f3", "e7 d5", "g2 g4", "d8 h4"]
    game_types[:scholars_mate] = ["e2 e4", "e7 e5", "d1 h5", "b8 c6", "f1 c4", "g8 f6", "h5 f7"]
    game_types[:white_pawn_promotion] = ["b2 b4", "h7 h6", "b4 b5", "g7 g6", "b5 b6", "f7 f6", "b6 a7", "e7 e6"]

    if game_types.keys.include?(test_type)
      g = ChessGame.new
      game_types[test_type].each do |input|
        move = g.pgn_to_coords(input)
        g.board.make_move(move)
        g.move_hashes << {piece: g.board[move[1]], move: move}
        g.switch_turn
      end
      g.play
    end
  end
end

if __FILE__ == $0
  ChessGame.load_test_game(:white_pawn_promotion)
  # ChessGame.new.play
end
