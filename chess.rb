class ChessGame
  attr_accessor :board
  # variables:  turn, board, players
  def initialize
    @board = new_board
  end

  def new_board
    Array.new(8) do |row|
      if row == 0
        Array.new(8) do |col|
          if col == 0 || col == 7
            Rook.new(([row, col]), :black)
          elsif col == 1 || col == 6
            Knight.new(([row, col]), :black)
          elsif col == 2 || col == 5
            Bishop.new(([row, col]), :black)
          elsif col == 4
            King.new(([row, col]), :black)
          else
            Queen.new(([row, col]), :black)
          end
        end
      elsif row == 1
        Array.new(8) { |col| Pawn.new(([row, col]), :black) }
      elsif row == 6
        Array.new(8) { |col| Pawn.new(([row, col]), :white) }
      elsif row == 7
        Array.new(8) do |col|
          if col == 0 || col == 7
            Rook.new(([row, col]), :white)
          elsif col == 1 || col == 6
            Knight.new(([row, col]), :white)
          elsif col == 2 || col == 5
            Bishop.new(([row, col]), :white)
          elsif col == 4
            King.new(([row, col]), :white)
          else
            Queen.new(([row, col]), :white)
          end
        end
      else
        Array.new(8)
      end
    end
  end

  def display_board
    board.each do |row|
      row.each do |piece|
        if piece
          print piece.to_s
        else
          print " "
        end
      end
      print "\n"
    end
  end

  def play
  end
end

class Piece
  attr_accessor :pos, :color, :unicode

  def initialize(pos, color)
    @pos = pos
    @color = color
    @unicode = ""
  end

  def to_s
    unicode
  end

end

class Pawn  < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2659" : "\u265F"
  end

  def move(user_input)

  end
end

class Knight < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2658" : "\u265E"
  end

  def move(user_input)

  end
end

class Bishop < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2657" : "\u265D"
  end

  def move(user_input)

  end
end

class Rook < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2656" : "\u265C"
  end

  def move(user_input)

  end
end

class Queen < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2655" : "\u265B"
  end

  def move(user_input)

  end
end

class King < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2654" : "\u265A"
  end

  def move(user_input)

  end
end


class HumanPlayer
  # vars: color
end

if __FILE__ == $0
  c = ChessGame.new
  c.display_board
end