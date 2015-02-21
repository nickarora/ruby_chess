class Piece

  attr_reader :color
  attr_accessor :pos, :prev_pos, :ever_moved

  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @prev_pos = nil
    @color = color
    @ever_moved = nil
  end

  def inspect
    { :piece_type => self.class,
      :pos => @pos,
      :color => @color
    }.inspect
  end

  def valid_moves
    moves.reject { |move| move_into_check?(move) }
  end

  def move_into_check?(end_pos)
    # Duplicate the board
    new_board = @board.dup

    # Perform the move
    new_board.move!(@pos, end_pos)

    # If in check return true
    new_board.in_check?(@color)
  end

end
