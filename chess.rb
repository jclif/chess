require 'debugger'
require './players.rb'
require './board.rb'
require './pieces.rb'
require 'colorize'
require 'yaml/store'

class ChessGame
  include MoveParser

  attr_accessor :board, :turn, :players, :move_hashes

  def self.new_game
    ChessGame.new.play
  end

  def self.load_test_game(test_type)

    game_types = {kingside: "g2 g3,g7 g6,f1 g2,f8 g7,g1 f3,g8 f6",
                  queenside: "b2 b3,b7 b6,b1 c3,b8 c6,c1 b2,c8 b7,d2 d3,d7 d6,d1 d2,d8 d7",
                  en_pass: "d2 d4,a7 a6,d4 d5,e7 e5"
    }

    if game_types.keys.include?(test_type)
      g = ChessGame.new
      game_types[test_type].split(",").each do |pair|
        g.board.make_move(g.convert(pair.split), g.move_hashes)
        g.switch_turn
      end
      g.play
    end
  end

  def initialize
    @board = Board.new
    @turn = :white
    @players = {white: HumanPlayer.new(:white), black: HumanPlayer.new(:black)}
    @move_hashes = []
  end

  def play

    #board.won?(board, move_hashes, turn) ||

    # get moves and make moves until game is won
    until board.draw?(turn, move_hashes)
      board.render(board, move_hashes, turn)
      move = players[turn].get_move(board, turn, move_hashes)
      board.make_move(move, move_hashes)
      self.move_hashes << {piece: board[move[1]], move: move}
      switch_turn
    end

    puts board.won?(board, move_hashes, turn) ? "Congrats!" : "Everybody wins!."
  end

  def switch_turn
    self.turn = turn == :white ? :black : :white
  end
end

if __FILE__ == $0
  ChessGame.load_test_game(:en_pass)
end
