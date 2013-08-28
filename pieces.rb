module MultiMover
  def get_peaceful_coords(board)
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

  def get_attack_coords(board)
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

class Pawn < Piece
  def initialize(pos, color)
    super(pos, color)
    @unicode = @color == :white ? "\u2659" : "\u265F"
  end

  def get_peaceful_coords(board)
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

  def get_attack_coords(board)
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

  def get_peaceful_coords(board)
    coords = []

    MOVE_DIFF.each do |diff|
      coords << [pos,diff].transpose.map { |x| x.reduce(:+) }
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_coords(board)
    #because they are identical
    get_peaceful_coords(board)
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
