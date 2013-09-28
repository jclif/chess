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
      puts "Enter your move, or q to quit! Ex: 'f2 f3'"
      input = gets.chomp

      abort("Thanks for playing!") if input == "q"
      next unless regexp.match(input)

      move = game.pgn_to_coords(input)
      break if game.board.valid?(move)
    end

    move
  end
end
