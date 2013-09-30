class Board
  attr_accessor :board, :game

  def initialize(game)
    @game = game
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
      if row == 0 || row == 7
        Array.new(8) do |col|
          if col == 0 || col == 7
            Rook.new([row, col], game)
          elsif col == 1 || col == 6
            Knight.new([row, col], game)
          elsif col == 2 || col == 5
            Bishop.new([row, col], game)
          elsif col == 4
            King.new([row, col], game)
          else
            Queen.new([row, col], game)
          end
        end
      elsif row == 1 || row == 6
        Array.new(8) { |col| Pawn.new([row, col], game) }
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

    if en_passant_move?(move)
      self[game.move_hashes.last[:move][1]] = nil
    else
      self[move[0]] = nil
    end

    self[move[1]].pos = move[1]

    piece = self[move[1]]

    if game.moving
      if piece.is_a?(Pawn)
        if piece.color == :white && piece.pos[0] == 0
          promote_pawn(piece)
        elsif piece.color == :black && piece.pos[0] == 7
          promote_pawn(piece)
        end
      end
    end
  end

  def promote_pawn(piece)
    # get a piece choice from user
    # create choosen piece on current pieces pos
    input = ""
    regexp = Regexp.new('[BNRQ]')
    until regexp.match(input)
      puts "Which piece would you like your pawn to become? ('B', 'N', 'R', 'Q')"
      input = gets.chomp
    end

    color = piece.color

    case input
    when 'B'
      new_piece = Bishop.new(piece.pos, game)
      self[piece.pos] = new_piece
      new_piece.color = color
    when 'N'
      new_piece = Knight.new(piece.pos, game)
      self[piece.pos] = new_piece
      new_piece.color = color
    when 'R'
      new_piece = Rook.new(piece.pos, game)
      self[piece.pos] = new_piece
      new_piece.color = color
    when 'Q'
      new_piece = Queen.new(piece.pos, game)
      self[piece.pos] = new_piece
      new_piece.color = color
    end
  end

  def en_passant_move?(move)
    return false unless !game.move_hashes.empty? && game.move_hashes.last[:piece].is_a?(Pawn) &&
    2 == (game.move_hashes.last[:move][0][0] - game.move_hashes.last[:move][1][0]).abs &&
    (move[1][1] == game.move_hashes.last[:move][1][1])

    true
  end

  def render

    puts "    a  b  c  d  e  f  g  h "
    game.board.board.each_with_index do |row, i|
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

    puts "You're in check." if check?
  end

  def valid?(move) # [[5, 5], [6, 5]]
    # finish refactoring
    from_pos, to_pos = move

    #check for piece of same color on end square
    from_piece = self[from_pos]

    #check to see if player can move from_piece
    return false unless from_piece.color == game.turn
    if en_passant_move?(move) && from_piece.get_attack_coords.include?(to_pos) && !yields_check?(move)
      return true
    end

    if self[to_pos] #theres a piece at to spot
      to_piece = self[to_pos]
      return false if to_piece.color == from_piece.color
      return false unless from_piece.get_attack_coords.include?(to_pos)
    else #there's no piece at to_pos
      return false unless from_piece.get_peaceful_coords.include?(to_pos)
    end

    return !yields_check?(move)
  end

  def yields_check?(move)
    yamlized_game = game.to_yaml

    g = YAML::load(yamlized_game)

    g.board.make_move(move)

    return g.board.check?
  end

  def check?
    game.board.board.each do |row|
      row.each_with_index do |piece, i|
        next if piece.nil? || piece.color == game.turn
        attack_coords = piece.get_attack_coords
        attack_coords.each do |coord|
          if game.board[coord].is_a?(King) && game.board[coord].color == game.turn
            return true
          end
        end
      end
    end

    false
  end

  def won?
    return false unless draw?
    return check?
  end

  def draw?
    board.each do |row|
      row.each do |piece|
        next if piece.nil? || piece.color != game.turn

        unless piece.get_peaceful_coords.empty? && piece.get_attack_coords.empty?
          coords = (piece.get_peaceful_coords + piece.get_attack_coords).keep_if { |c| valid?([piece.pos, c]) }

          return false unless coords.empty?
        end
      end
    end

    true
  end
end
