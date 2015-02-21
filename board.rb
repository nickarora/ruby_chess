class EmptyPosError < ArgumentError
end

class InvalidMoveError < ArgumentError
end

class WrongPieceError < ArgumentError
end

class NilPieceError < ArgumentError
end

class Board

  attr_accessor :grid

  def initialize(set_up_flag = true)
    @grid = set_up_board(set_up_flag)
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, element)
    row, col = pos
    @grid[row][col] = element
  end

  def inspect
    nil
  end

  def toggle(color)
    color == 'w' ? 'b' : 'w'
  end

  def in_check?(color)
    king = entire_color(color).find { |p| p.is_a? King }

    possible_moves = []
    entire_color(toggle(color)).each do |piece|
      possible_moves += piece.moves
    end

    possible_moves.include? king.pos
  end

  def checkmate?(color)
    possible_moves = []
    entire_color(color).each do |piece|
      possible_moves += piece.valid_moves
    end

    possible_moves.empty?
  end

  def move(start_pos, end_pos, color)
    raise NilPieceError.new("You selected a blank piece!") if self[start_pos].nil?
    raise WrongPieceError.new ("Not your Piece!") if self[start_pos].color != color

    return if handle_special_moves(start_pos, end_pos)

    current_piece = self[start_pos]
    raise EmptyPosError if current_piece.nil?
    if !perform_move(start_pos, end_pos, current_piece.valid_moves, current_piece)
      raise InvalidMoveError.new("Not a valid move!")
    end
  end

  def move!(start_pos, end_pos)
    current_piece = self[start_pos]
    raise EmptyPosError if current_piece.nil?
    perform_move(start_pos, end_pos, current_piece.moves, current_piece)
  end

  def dup
    new_board = Board.new(false)

    duplicate = Array.new(8) { Array.new(8) }

    @grid.flatten.compact.each do |item|
      new_board[item.pos] = item.class.new(new_board, item.pos, item.color)
    end

    new_board
  end

  def handle_promotions
    pieces = @grid.flatten.compact.select { |piece| piece.pos[0] == 0 || piece.pos[0] == 7 }
    pawns = pieces.select { |piece| piece.is_a?(Pawn) }
    pawns.each do |pawn|
      pos = pawn.pos
      color = pawn.color
      self[pos] = Queen.new(self, pos, color)
    end

    nil
  end

  def entire_color(color)
    @grid.flatten.compact.select { |p| p.color == color }
  end

  def render(cursor = nil)
    puts "  a b c d e f g h"
    @grid.each_with_index do |row, row_index|
      print "#{row_index} "
      row.each_with_index do |item, col_index|

        colored_space = (row_index + col_index).odd? ? :white : :black
        colored_space = :green if cursor && cursor == [row_index, col_index]

        render_tile(item, colored_space)
      end
      puts "\n"
    end
    puts "\n"
    nil
  end

  def valid_move?(color, pos)
    row, col = pos

    # Within the board?
    return false if row < 0 || row > 7
    return false if col < 0 || col > 7

    current_piece = @grid[row][col]
    return true if current_piece.nil?

    # Hit its own piece?
    return false if current_piece.color == color

    true
  end

  private

  def set_up_board(set_up_flag)
    temp_grid = Array.new(8) { Array.new(8) }

    if set_up_flag
      # Place Pieces!
      (0..7).each do |col|
        temp_grid[1][col] = Pawn.new(self, [1,col], 'b')
        temp_grid[6][col] = Pawn.new(self, [6,col], 'w')
      end

      [[0,'b'], [7,'w']].each do |row, color|
        [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook].each_with_index do |type, col|
          temp_grid[row][col] = type.new(self, [row, col], color)
        end
      end
    end

    temp_grid
  end

  def perform_move(start_pos, end_pos, available_moves, current_piece)
    return false unless available_moves.include?(end_pos)
    self[end_pos] = current_piece
    self[start_pos] = nil
    current_piece.ever_moved ||= true
    current_piece.pos = end_pos
    current_piece.prev_pos = start_pos
    true
  end

  def handle_special_moves(start_pos, end_pos)
    # Castling
    if castle_possible?(start_pos, end_pos)
      castle(start_pos, end_pos)
      return true
    end

    # En Passant
    if en_passant_possible?(start_pos, end_pos)
      en_passant(start_pos, end_pos)
      return true
    end

    false
  end

  def castle(start_pos, end_pos)
    direction = (end_pos[1] > 3) ? [6,5] : [1,2]
    e_row, e_col = end_pos
    perform_move(start_pos, [e_row, direction[0]], [[e_row, direction[0]]], self[start_pos]) #King
    perform_move(end_pos, [e_row, direction[1]], [[e_row, direction[1]]], self[end_pos]) #Rook

    nil
  end

  def castle_possible?(start_pos, end_pos)
    curr_piece = self[start_pos]
    dest_piece = self[end_pos]

    return false unless curr_piece.is_a?(King) && dest_piece.is_a?(Rook)
    return false if curr_piece.ever_moved || dest_piece.ever_moved
    col_between = ((start_pos[1] + 1)...end_pos[1]).to_a
    positions = col_between.map {|col| [start_pos[0], col] }
    return false unless positions.all? {|pos| self[pos].nil? }

    true
  end

  def en_passant(start_pos, end_pos)
    e_row, e_col = end_pos
    direction = self[start_pos].color == 'w' ? -1 : 1

    perform_move(start_pos, [e_row + direction, e_col], [[e_row + direction, e_col]], self[start_pos])
    self[end_pos] = nil

    nil
  end

  def en_passant_possible?(start_pos, end_pos)
    curr_piece = self[start_pos]
    dest_piece = self[end_pos]

    s_row, s_col = start_pos
    e_row, e_col = end_pos

    direction = self[start_pos].color == 'w' ? -1 : 1

    return false unless curr_piece.is_a?(Pawn) && dest_piece.is_a?(Pawn)
    return false unless curr_piece.color != dest_piece.color
    return false unless s_row == e_row
    return false unless (e_col - s_col).abs == 1
    return false unless (dest_piece.prev_pos[0] - dest_piece.pos[0]).abs == 2
    return false unless self[[e_row + direction, e_col]].nil?

    true
  end

  def render_tile(item, color)
    if item == nil
      print "  ".send("on_#{color}")
    else
      print item.symbol.red.send("on_#{color}") if item.color == 'w'
      print item.symbol.blue.send("on_#{color}") if item.color == 'b'
      print " ".send("on_#{color}")
    end
  end
end
