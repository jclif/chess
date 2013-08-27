require 'debugger'; debugger

module MoveParser
  def convert(move) # ["f2", "f3"] => [[6,5],[5,5]]
    move.map! do |pos|
      col = ("a".."h").to_a.index(pos[0])
      [8-pos[1].to_i, col]
    end

    move
  end
end

module MultiMover
  def get_peaceful_poss(board)
    coords = []

    self.class::MOVE_DIFF.each do |diff|
      i = 1
      until i == self.class::MOVE_LENGTH

        multiplied = [diff[0] * i, diff[1] * i]
        trans = [pos,multiplied].transpose.map { |x| x.reduce(:+) }

        break if !(on_board?(trans)) || board[trans[0]][trans[1]]

        coords << trans

        i += 1
      end
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_poss(board)
    coords = []
    add_to_coords = nil

    self.class::MOVE_DIFF.each do |diff|
      i = 1
      until i == self.class::MOVE_LENGTH

        multiplied = [diff[0] * i, diff[1] * i]
        trans = [pos,multiplied].transpose.map { |x| x.reduce(:+) } # [2, 2]

        add_to_coords = trans

        break if !(on_board?(trans)) || board[trans[0]][trans[1]]

        i += 1
      end

      coords << add_to_coords
    end

    coords.keep_if { |p| on_board?(p) && p != pos }
  end
end

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
      board.render

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

  def valid?(move, turn) # [[5, 5], [6, 5]]

    from_pos, to_pos = move

    return false unless self[from_pos]
    #check for piece of same color on end square
    from_piece = self[from_pos]

    #check to see if player can move from_piece
    return false unless from_piece.color == turn

    if self[to_pos] #theres a piece at to spot
      to_piece = self[to_pos]
      return false if to_piece.color == from_piece.color
      return false unless from_piece.get_attack_poss(board).include?(to_pos)
    else #there's no piece at to_pos
      return false unless from_piece.get_peaceful_poss(board).include?(to_pos)
    end

    #make sure to_square is included in valid_moves of piece at from_square

    true

    #hypothetically make move to see if king was in check
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

  def on_board?(to_pos)
    to_pos[0].between?(0, 7) && to_pos[1].between?(0, 7)
  end

end

class Pawn  < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2659" : "\u265F"
  end

  def get_peaceful_poss(board)
    coords = []
    if color == :white
      coords << [pos[0] - 1, pos[1]]
      coords << [pos[0] - 2, pos[1]] if pos[0] == 6
    else
      coords << [pos[0] + 1, pos[1]]
      coords << [pos[0] + 2, pos[1]] if pos[0] == 1
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_poss(board)
    coords = []
    if color == :white
      coords << [pos[0] - 1, pos[1] - 1]
      coords << [pos[0] - 1, pos[1] + 1]
    else
      coords << [pos[0] + 1, pos[1] - 1]
      coords << [pos[0] + 1, pos[1] + 1]
    end

    coords.keep_if { |p| on_board?(p) }
  end
end

class Knight < Piece
  MOVE_DIFF = [[1,2],[2,1],[-1,2],[2,-1],[1,-2],[-2,1],[-1,-2],[-2,-1]]
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2658" : "\u265E"
  end

  def get_peaceful_poss(board)
    coords = []

    MOVE_DIFF.each do |diff|
      coords << [pos,diff].transpose.map { |x| x.reduce(:+) }
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_poss(board)
    #because they are identical
    get_peaceful_poss(board)
  end
end

class Bishop < Piece
  include MultiMover

  MOVE_DIFF = [[-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 8

  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2657" : "\u265D"
  end
end

class Rook < Piece
  include MultiMover

  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1]]
  MOVE_LENGTH = 8

  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2656" : "\u265C"
  end
end

class Queen < Piece
  include MultiMover

  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1], [-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 8

  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2655" : "\u265B"
  end
end

class King < Piece
  include MultiMover

  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1], [-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 2

  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2654" : "\u265A"
  end

end

class HumanPlayer
  include MoveParser

  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def get_move(board, turn)
    puts "Enter your move. Ex: 'f2 f3'"
    answer = gets.chomp.split

    unless board.valid?(convert(answer), turn)
      raise StandardError.new "Invalid move. Try again loser!"
    end

    answer
  rescue StandardError => e
    puts e.message
    retry
  end

end

if __FILE__ == $0
  c = ChessGame.new
  c.play
end
