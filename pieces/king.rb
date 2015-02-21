class King < Piece

  include SteppingPiece

  DIRECTIONS = [[-1,-1], [-1,1], [1,-1], [1,1], [1,0], [0,1], [-1,0], [0,-1]]

  def moves
    stepping_move(DIRECTIONS)
  end

  def symbol
    # @color == 'w' ? '♔' : '♚'
    '♚'
  end

end
