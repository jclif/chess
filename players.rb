class HumanPlayer

  attr_accessor :color, :game

  def initialize(color, game)
    @color = color
    @game = game
  end

  def get_move
    regexp = Regexp.new('[a-h][0-8] [a-h][0-8]')
    move = ""

    loop do
      puts "Enter your move. Ex: 'f2 f3'"
      input = gets.chomp
      move = game.pgn_to_coords(input)

      break if regexp.match(input) && game.board.valid?(move)
    end

    move
  end
end
