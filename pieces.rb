module MultiMover
  def get_peaceful_coords(board, move_hashes, turn)
    coords = []

    self.class::MOVE_DIFF.each do |diff|
      i = 1
      until i == self.class::MOVE_LENGTH

        multiplied = [diff[0] * i, diff[1] * i]
        trans = [pos,multiplied].transpose.map { |x| x.reduce(:+) }

        break if !(on_board?(trans)) || board[trans[0], trans[1]]

        coords << trans

        i += 1
      end
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_coords(board, move_hashes, turn)
    board = board.board if board.is_a?(Board)


    coords = []
    add_to_coords = nil

    self.class::MOVE_DIFF.each do |diff|
      i = 1
      until i == self.class::MOVE_LENGTH

        multiplied = [diff[0] * i, diff[1] * i]
        trans = [pos,multiplied].transpose.map { |x| x.reduce(:+) } # [2, 2]

        add_to_coords = trans

        break if !(on_board?(trans)) || board[trans[0], trans[1]]

        i += 1
      end

      coords << add_to_coords
    end

    coords.keep_if { |p| on_board?(p) && p != pos }
  end
end

class Piece
  include MultiMover

  attr_accessor :pos, :color, :unicode

  def initialize(pos)
    @pos = pos
    @color = get_color
    @unicode = ""
  end

  def to_s
    unicode
  end

  def get_color
    return [6, 7].include?(pos[0]) ? :white : :black
  end

  def on_board?(to_pos)
    to_pos[0].between?(0, 7) && to_pos[1].between?(0, 7)
  end

end

class Pawn < Piece
  def initialize(pos)
    super(pos)
    @unicode = @color == :white ? "\u2659" : "\u265F"
  end

  def get_peaceful_coords(board, move_hashes, turn)
    coords = []
    if color == :white
      coords << [pos[0] - 1, pos[1]]
      coords << [pos[0] - 2, pos[1]] if pos[0] == 6 && board[(pos[0] - 1), pos[1]].nil?
    else
      coords << [pos[0] + 1, pos[1]]
      coords << [pos[0] + 2, pos[1]] if pos[0] == 1 && board[(pos[0] + 1), pos[1]].nil?
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_coords(board, move_hashes, turn)
    coords = []
    if color == :white
      coords << [pos[0] - 1, pos[1] - 1]
      coords << [pos[0] - 1, pos[1] + 1]
    else
      coords << [pos[0] + 1, pos[1] - 1]
      coords << [pos[0] + 1, pos[1] + 1]
    end

    debugger

    if color == :white
      if en_passant?(:right, board, move_hashes, turn)
        coords << [pos[0] - 1, pos[1] + 1]
      end

      if en_passant?(:left, board, move_hashes, turn)
        coords << [pos[0] - 1, pos[1] - 1]
      end
    else
      if en_passant?(:right, board, move_hashes, turn)
        coords << [pos[0] + 1, pos[1] + 1]
      end

      if en_passant?(:left, board, move_hashes, turn)
        coords << [pos[0] + 1, pos[1] - 1]
      end
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def en_passant?(direction, board, move_hashes, turn)
    if color == :white?
      return false unless pos[0] == 3
    else
      return false unless pos[0] == 4
    end

    return false unless move_hashes.last[:piece].is_a?(Pawn)

    enemy_start_pos = move_hashes.last[:move][0]
    enemy_end_pos = move_hashes.last[:move][1]

    if color == :white?
      unless (enemy_start_pos[0] == pos[0] - 1) && (enemy_end_pos[0] == pos[0])
        return false
      end
    else
      unless (enemy_start_pos[0] == pos[0] + 1) && (enemy_end_pos[0] == pos[0])
        return false
      end
    end

    if direction == :right
      unless (enemy_start_pos[1] == pos[1] + 1) && (enemy_end_pos[1] == pos[1] + 1)
        return false
      end
    else
      unless (enemy_start_pos[1] == pos[1] - 1) && (enemy_end_pos[1] == pos[1] - 1)
        return false
      end
    end

    true
  end
end

class Knight < Piece
  MOVE_DIFF = [[1,2],[2,1],[-1,2],[2,-1],[1,-2],[-2,1],[-1,-2],[-2,-1]]
  def initialize(pos)
    super(pos)
    @unicode = @color == :white ? "\u2658" : "\u265E"
  end

  def get_peaceful_coords(board, move_hashes, turn)
    coords = []

    MOVE_DIFF.each do |diff|
      coords << [pos,diff].transpose.map { |x| x.reduce(:+) }
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_coords(board, move_hashes, turn)
    #because they are identical
    get_peaceful_coords(board, move_hashes, turn)
  end
end

class Bishop < Piece
  MOVE_DIFF = [[-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 8

  def initialize(pos)
    super(pos)
    @unicode = @color == :white ? "\u2657" : "\u265D"
  end
end

class Rook < Piece
  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1]]
  MOVE_LENGTH = 8

  def initialize(pos)
    super(pos)
    @unicode = @color == :white ? "\u2656" : "\u265C"
  end
end

class Queen < Piece
  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1], [-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 8

  def initialize(pos)
    super(pos)
    @unicode = @color == :white ? "\u2655" : "\u265B"
  end
end

class King < Piece
  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1], [-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 2

  def initialize(pos)
    super(pos)
    @unicode = @color == :white ? "\u2654" : "\u265A"
  end

  def get_peaceful_coords(board, move_hashes, turn)
    coords = super

    co = castle_options(board, move_hashes, turn) # :kingside, #queenside #both #neither

    case co
    when :kingside
      y = turn == :white ? 7 : 0
      coords << [y, 6]
    when :queenside
      y = turn == :white ? 7 : 0
      coords << [y, 2]
    when :both
      y = turn == :white ? 7 : 0
      coords << [y, 6]
      coords << [y, 2]
    end

    coords
  end

  def castle_options(board, move_hashes, turn)
    #not in check currently
    return :neither if board.check?(board, move_hashes, turn)

    king = board.board.flatten.select { |piece| piece && piece.is_a?(King) && piece.color == turn}[0]

    #king hasnt moved
    return :neither if move_hashes.any? { |hash| hash.has_value?(king) }

    q_rook = board.board.flatten.select { |piece| piece && piece.is_a?(Rook) && piece.color == turn && piece.pos[1] == 0}[0]

    can_castle_queenside = can_castle?(q_rook, king, move_hashes, board, turn)

    k_rook = board.board.flatten.select { |piece| piece && piece.is_a?(Rook) &&
      piece.color == turn && piece.pos[1] == 7}[0]

    can_castle_kingside = can_castle?(k_rook, king, move_hashes, board, turn)

    if can_castle_kingside && can_castle_queenside
      return :both
    elsif can_castle_kingside
      return :kingside
    elsif can_castle_queenside
      return :queenside
    else
      return :neither
    end
  end

  def can_castle?(rook, king, move_hashes, board, turn)
    return false if move_hashes.any? { |hash| hash.has_value?(rook) }

    if rook.pos[1] == 0 #if it's queenside
      path = [[rook.pos[0], 1], [rook.pos[0], 2], [rook.pos[0], 3]]
    else #if it's kingside
      path = [[rook.pos[0], 5], [rook.pos[0], 6]]
    end

    #check for pieces in path
    return false if path.any? { |coord| board[coord] }

    board.board.each do |row|
      row.each do |piece|
        next if piece.nil? || piece.color == turn

        return false unless (piece.get_attack_coords(board, move_hashes, turn) & path).empty?

      end
    end

    true
  end
end
