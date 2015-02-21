class Knight < Piece

  include SteppingPiece

  DIRECTIONS = [
    [-2, -1],
    [-2,  1],
    [-1, -2],
    [-1,  2],
    [ 1, -2],
    [ 1,  2],
    [ 2, -1],
    [ 2,  1]
  ]

  def moves
    stepping_move(DIRECTIONS)
  end

  def symbol
    # @color == 'w' ? '♘' : '♞'
    '♞'
  end


end
