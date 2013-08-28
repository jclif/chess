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

  def make_move(move) # [[6,0],[5,0]]
    captured_piece = self[move[1]]

    self[move[1]] = self[move[0]]
    self[move[0]] = nil
    self[move[1]].pos = move[1]

    captured_piece
  end

  def unmake_move(captured_piece, move)
    self[move[0]] = self[move[1]]
    self[move[1]] = captured_piece
    self[move[0]].pos = move[0]
  end

  def render(turn)

    puts "    a  b  c  d  e  f  g  h "
    board.each_with_index do |row, i|
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

    puts "You're in check." if check?(turn)
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
      return false unless from_piece.get_attack_coords(board).include?(to_pos)
    else #there's no piece at to_pos
      return false unless from_piece.get_peaceful_coords(board).include?(to_pos)
    end

    #hypothetically make move to see if king was in check
    return doesnt_yield_check?(move, turn)

    true
  end

  def doesnt_yield_check?(move, turn)
    captured_piece = make_move(move)

    no_check = !(check?(turn))

    unmake_move(captured_piece, move)

    no_check
  end

  def check?(turn) #white's turn, white's king
    board.each do |row|
      row.each_with_index do |piece, i|
        next if piece.nil? || piece.color == turn
        attack_coords = piece.get_attack_coords(board)
        attack_coords.each do |coord|
          if self[coord].is_a?(King) && self[coord].color == turn
            return true
          end
        end
      end
    end

    false
  end

  def won?(turn)
    return false unless draw?(turn)
    return check?(turn)
  end

  def draw?(turn)
    board.each do |row|
      row.each do |piece|
        next if piece.nil?
        next unless piece.color == turn
        unless piece.get_peaceful_coords(board).empty? &&
          piece.get_attack_coords(board).empty?
          coords = piece.get_peaceful_coords(board) + piece.get_attack_coords(board)
          coords.keep_if do |coord|
            valid?([piece.pos, coord], turn)
          end
          return false unless coords.empty?
        end
      end
    end

    true
  end
end