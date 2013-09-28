module MoveParser
  def pgn_to_coords(input) # ["f2", "f3"] => [[6,5],[5,5]]
    input_array = input.split

    coords = input_array.map do |pos|
      col = ("a".."h").to_a.index(pos[0])
      [8-pos[1].to_i, col]
    end

    coords
  end
end

