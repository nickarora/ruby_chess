class Pawn < Piece

  WHITE_ATTACK = [[-1,1], [-1,-1]]
  BLACK_ATTACK = [[1,-1], [1,1]]

  def moves
    if @color == 'w'
      color_based_moves(WHITE_ATTACK, -1, 6)
    else
      color_based_moves(BLACK_ATTACK, 1, 1)
    end
  end

  def color_based_moves(attack_moves, dir, start)
    possible_moves = []
    row, col = @pos

    possible_moves << [row + dir, col] if @board[[row + dir, col]].nil?
    if row == start
      possible_moves << [row + (dir * 2), col] if @board[[row + (dir * 2), col]].nil?
    end

    possible_moves += get_attack_moves(attack_moves)

    possible_moves
  end

  def get_attack_moves(attack_moves)
    possible_moves = []
    row, col = @pos

    attack_moves.each do |vert, horiz|
      if !@board[[row + vert,col + horiz]].nil? && @board[[row + vert,col + horiz]].color != @color
        possible_moves << [row + vert,col + horiz]
      end
    end

    possible_moves
  end

  def symbol
    # @color == 'w' ? '♙' : '♟'
    '♟'
  end

end
