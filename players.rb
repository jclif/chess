module MoveParser
  def convert(move) # ["f2", "f3"] => [[6,5],[5,5]]
    move.map! do |pos|
      col = ("a".."h").to_a.index(pos[0])
      [8-pos[1].to_i, col]
    end

    move
  end
end

class HumanPlayer
  include MoveParser

  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def get_move(board, turn, move_hashes)
    puts "Enter your move. Ex: 'f2 f3'"
    answer = gets.chomp.split

    unless board.valid?(convert(answer), turn, move_hashes)
      raise StandardError.new "Invalid move. Try again loser!"
    end

    answer
  rescue StandardError => e
    puts e.message
    retry
  end
end