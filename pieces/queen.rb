class Queen < Piece

  include SlidingPiece

  def moves
    sliding_moves(ORTH + DIAG)
  end

  def symbol
    # @color == 'w' ? '♕' : '♛'
    '♛'
  end

end
