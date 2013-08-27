class ChessGame
  attr_accessor :board, :turn, :players
  # variables:  turn, board, players
  def initialize
    @board = Board.new
    @turn = :white
    @players = {white: HumanPlayer.new(:white), black: HumanPlayer.new(:black)}
  end

  def play
    # get moves and make moves until game is won
    until board.won? || board.draw?
      board.render

      players[turn].get_move
      make_move
    end
  end
end

class Board
  attr_accessor :board

  def initialize
    @board = new_board
  end

  def [](*args)
    if args.length == 2
      board[args[0]][args[1]]
    elsif args.length == 1
      board[args[0][0]][args[0][1]]
    else
      raise StandardError "Square brackets needs 1 or 2 arguments."
    end
  rescue StandardError => e
    puts e.message
    puts args
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

  def render
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

  def valid?(move) # ["f2", "f3"]
    from_coord, to_coord = convert(move)

    return false unless self[from_coord]
    #check for piece of same color on end square
    from_piece = self[from_coord]

    if self[to_coord] #theres a piece at to spot
      to_piece = self[to_coord]
      return false if to_piece.color == from_piece.color
      #the piece is attacking
    end

    #make sure to_square is included in valid_moves of piece at from_square

    true

    #hypothetically make move to see if king was in check
  end

  def convert(move) # ["f2", "f3"] => [[6,5],[5,5]]
    move.map! do |coord|
      col = ("a".."h").to_a.index(coord[0])
      [8-coord[1].to_i, col]
    end

    move
  end

  def won?
    # check that king is under attack and there is no move to uncheck
    false
  end

  def draw?
    # there's no legal move
    false
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
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def get_move
    puts "Enter your move. Ex: 'f2 f3'"
    answer = gets.chomp.split

    unless board.valid?(answer)
      StandardError.new "Invalid move. Try again loser!"
    end
  rescue StandError => e
    puts e.message
    retry
  end

end

if __FILE__ == $0
  b = ChessGame.new.board
end

module StraightMover
  #how rooks, kings, queens move
end

module DiagMover
  #how bishops, kings, and queens move
end

module MultiMover
  #how bishops, rooks, and queens move
end