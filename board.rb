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