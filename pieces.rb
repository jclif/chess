class Piece

  attr_accessor :pos, :color, :unicode, :game

  def initialize(pos, game)
    @pos = pos
    @color = get_color
    @unicode = ""
    @game = game
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
  def initialize(pos, game)
    super(pos, game)
    @unicode = @color == :white ? "\u2659" : "\u265F"
  end

  def get_peaceful_coords
    coords = []
    if color == :white
      coords << [pos[0] - 1, pos[1]]
      coords << [pos[0] - 2, pos[1]] if pos[0] == 6 && game.board[(pos[0] - 1), pos[1]].nil?
    else
      coords << [pos[0] + 1, pos[1]]
      coords << [pos[0] + 2, pos[1]] if pos[0] == 1 && game.board[(pos[0] + 1), pos[1]].nil?
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_coords
    coords = []
    if color == :white
      coords << [pos[0] - 1, pos[1] - 1]
      coords << [pos[0] - 1, pos[1] + 1]
    else
      coords << [pos[0] + 1, pos[1] - 1]
      coords << [pos[0] + 1, pos[1] + 1]
    end

    if color == :white
      if en_passant?(:right)
        coords << [pos[0] - 1, pos[1] + 1]
      end

      if en_passant?(:left)
        coords << [pos[0] - 1, pos[1] - 1]
      end
    else
      if en_passant?(:right)
        coords << [pos[0] + 1, pos[1] + 1]
      end

      if en_passant?(:left)
        coords << [pos[0] + 1, pos[1] - 1]
      end
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def en_passant?(direction)
    if color == :white?
      return false unless pos[0] == 3
    else
      return false unless pos[0] == 4
    end

    return false unless game.move_hashes.last[:piece].is_a?(Pawn)

    enemy_start_pos = game.move_hashes.last[:move][0]
    enemy_end_pos = game.move_hashes.last[:move][1]

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
  def initialize(pos, game)
    super(pos, game)
    @unicode = @color == :white ? "\u2658" : "\u265E"
  end

  def get_peaceful_coords
    coords = []

    MOVE_DIFF.each do |diff|
      coords << [pos,diff].transpose.map { |x| x.reduce(:+) }
    end

    coords.keep_if { |p| on_board?(p) }
  end

  def get_attack_coords
    #because they are identical
    get_peaceful_coords
  end
end

class MultiMover < Piece
  def initialize(pos, game)
    super(pos,game)
  end

  def get_peaceful_coords
    coords = []

    self.class::MOVE_DIFF.each do |diff|
      i = 1
      until i == self.class::MOVE_LENGTH

        multiplied = [diff[0] * i, diff[1] * i]
        trans = [pos,multiplied].transpose.map { |x| x.reduce(:+) }

        break if !(on_board?(trans)) || game.board[trans[0], trans[1]]

        coords << trans

        i += 1
      end
    end

    coords.keep_if { |coord| on_board?(coord) }
  end

  def get_attack_coords

    coords = []
    add_to_coords = nil

    self.class::MOVE_DIFF.each do |diff|
      i = 1
      until i == self.class::MOVE_LENGTH

        multiplied = [diff[0] * i, diff[1] * i]
        trans = [pos,multiplied].transpose.map { |x| x.reduce(:+) } # [2, 2]

        add_to_coords = trans
        break if !(on_board?(trans)) || game.board[trans[0], trans[1]]

        i += 1
      end

      coords << add_to_coords
    end

    coords.keep_if { |p| on_board?(p) && p != pos }
  end
end

class Bishop < MultiMover
  MOVE_DIFF = [[-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 8

  def initialize(pos, game)
    super(pos, game)
    @unicode = @color == :white ? "\u2657" : "\u265D"
  end
end

class Rook < MultiMover
  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1]]
  MOVE_LENGTH = 8

  def initialize(pos, game)
    super(pos, game)
    @unicode = @color == :white ? "\u2656" : "\u265C"
  end
end

class Queen < MultiMover
  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1], [-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 8

  def initialize(pos, game)
    super(pos, game)
    @unicode = @color == :white ? "\u2655" : "\u265B"
  end
end

class King < MultiMover
  MOVE_DIFF = [[1,0], [-1, 0], [0, 1], [0, -1], [-1, -1], [1, 1], [1, -1], [-1, 1]]
  MOVE_LENGTH = 2

  def initialize(pos, game)
    super(pos, game)
    @unicode = @color == :white ? "\u2654" : "\u265A"
  end

  def get_peaceful_coords
    coords = super

    co = castle_options # :kingside, #queenside #both #neither

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

  def castle_options
    #not in check currently
    return :neither if game.board.check?

    king = game.board.board.flatten.select { |piece| piece && piece.is_a?(King) && piece.color == game.turn}[0]

    #king hasnt moved
    return :neither if game.move_hashes.any? { |hash| hash.has_value?(king) }

    q_rook = game.board.board.flatten.select { |piece| piece && piece.is_a?(Rook) && piece.color == game.turn && piece.pos[1] == 0}[0]

    can_castle_queenside = can_castle?(q_rook, king)

    k_rook = game.board.board.flatten.select { |piece| piece && piece.is_a?(Rook) &&
      piece.color == game.turn && piece.pos[1] == 7}[0]

    can_castle_kingside = can_castle?(k_rook, king)

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

  def can_castle?(rook, king)
    return false if game.move_hashes.any? { |hash| hash.has_value?(rook) }

    if rook.pos[1] == 0 #if it's queenside
      path = [[rook.pos[0], 1], [rook.pos[0], 2], [rook.pos[0], 3]]
    else #if it's kingside
      path = [[rook.pos[0], 5], [rook.pos[0], 6]]
    end

    #check for pieces in path
    return false if path.any? { |coord| game.board[coord] }

    board.board.each do |row|
      row.each do |piece|
        next if piece.nil? || piece.color == game.turn

        return false unless (piece.get_attack_coords & path).empty?

      end
    end

    true
  end
end
