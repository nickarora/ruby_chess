module SlidingPiece

  DIAG = [[-1,-1], [-1,1], [1,-1], [1,1]]
  ORTH = [[1,0], [0,1], [-1,0], [0,-1]]

  def sliding_moves(direction)
    possible_moves = []

    direction.each do |vert, horiz|
      cur_row, cur_col = @pos
      cur_row += vert
      cur_col += horiz

      while @board.valid_move?(@color, [cur_row, cur_col])
        possible_moves << [cur_row, cur_col]
        cur_row += vert
        cur_col += horiz

        unless @board[possible_moves.last].nil?
          break if @board[possible_moves.last].color != @color
        end
      end
    end

    possible_moves
  end
end
