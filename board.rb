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
      raise StandardError.new "Square brackets needs 1 or 2 arguments."
    end
  rescue StandardError => e
    puts e.message
    puts args
  end

  def []=(*args)
    value = args.pop
    if args.length == 2
      board[args[0]][args[1]] = value
    elsif args.length == 1
      board[args[0][0]][args[0][1]] = value
    else
      raise StandardError.new "Square brackets needs 1 or 2 arguments."
    end
  rescue StandardError => e
    puts e.message
    puts args
  end

  def new_board
    Array.new(8) do |row|
      if row == 0 || row == 7 #row 0 is black, row 7 is white
        Array.new(8) do |col|
          if col == 0 || col == 7
            Rook.new([row, col])
          elsif col == 1 || col == 6
            Knight.new([row, col])
          elsif col == 2 || col == 5
            Bishop.new([row, col])
          elsif col == 4
            King.new([row, col])
          else
            Queen.new([row, col])
          end
        end
      elsif row == 1 || row == 6 #row 1 is black, row 6 is white
        Array.new(8) { |col| Pawn.new([row, col]) }
      else
        Array.new(8)
      end
    end
  end

  def make_move(move) # [[6,0],[5,0]]
    if self[move[0]].is_a?(King)
      black_queenside = [[0, 4], [0, 2]]
      black_kingside = [[0, 4], [0, 6]]
      white_queenside = [[7, 4], [7, 2]]
      white_kingside = [[7, 4], [7, 6]]

      case move
      when black_queenside
        make_move([[0, 0],[0, 3]])
      when black_kingside
        make_move([[0, 7],[0, 5]])
      when white_queenside
        make_move([[7, 0],[7, 3]])
      when white_kingside
        make_move([[7, 7],[7, 5]])
      end
    end

    self[move[1]] = self[move[0]]
    self[move[0]] = nil
    self[move[1]].pos = move[1]

  end

  def render(board, move_hashes, turn)

    puts "    a  b  c  d  e  f  g  h "
    @board.each_with_index do |row, i|
      print " #{8 - i} "
      row.each_with_index do |piece, j|
        color = (i + j).even? ? :light_cyan : :cyan
        if piece
          print " #{piece} ".colorize(:background => color)
        else
          print "   ".colorize( :background => color )
        end
      end
      print "\n"
    end

    puts "You're in check." if check?(self, move_hashes, turn)
  end

  def valid?(move, turn, move_hashes) # [[5, 5], [6, 5]]

    from_pos, to_pos = move

    return false unless self[from_pos]
    #check for piece of same color on end square
    from_piece = self[from_pos]

    #check to see if player can move from_piece
    return false unless from_piece.color == turn

    if self[to_pos] #theres a piece at to spot
      to_piece = self[to_pos]
      return false if to_piece.color == from_piece.color
      return false unless from_piece.get_attack_coords(self, move_hashes, turn).include?(to_pos)
    else #there's no piece at to_pos
      return false unless from_piece.get_peaceful_coords(self, move_hashes, turn).include?(to_pos)
    end

    #hypothetically make move to see if king was in check
    return doesnt_yield_check?(self, move_hashes, turn, move)

    true
  end

  def doesnt_yield_check?(board, move_hashes, turn, move)
    yamlized_board = board.to_yaml

    b = YAML::load(yamlized_board)

    b.make_move(move)

    !b.check?(b, move_hashes, turn)
  end

  def dup(move_hashes)
    b = Board.new


  end

  def check?(b, move_hashes, turn) #white's turn, white's king
    b.board.each do |row|
      row.each_with_index do |piece, i|
        next if piece.nil? || piece.color == turn
        attack_coords = piece.get_attack_coords(b, move_hashes, turn)
        attack_coords.each do |coord|
          if b[coord].is_a?(King) && b[coord].color == turn
            return true
          end
        end
      end
    end

    false
  end

  def won?(board, turn, move_hashes)
    return false unless draw?(turn, move_hashes)
    return check?(self, move_hashes, turn)
  end

  def draw?(turn, move_hashes)

    board.each do |row|
      row.each do |piece|
        next if piece.nil?
        next unless piece.color == turn
        unless piece.get_peaceful_coords(self, move_hashes, turn).empty? &&
          piece.get_attack_coords(self, move_hashes, turn).empty?
          coords = piece.get_peaceful_coords(self, move_hashes, turn) +
            piece.get_attack_coords(self, move_hashes, turn)
          coords.keep_if do |coord|
            valid?([piece.pos, coord], turn, move_hashes)
          end
          return false unless coords.empty?
        end
      end
    end

    true
  end
end