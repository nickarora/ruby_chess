class ComputerPlayer

  attr_reader :color
  attr_accessor :board

  def initialize(board, color)
    @board = board
    @color = color
  end

  def select_piece
    all_pieces = @board.entire_color(@color)

    killer_pieces = []
    all_pieces.each do |piece|
      piece.valid_moves.each do |pos|
        killer_pieces << piece if !@board[pos].nil?
      end
    end

    if killer_pieces.empty?
      @selected_piece = @board.entire_color(@color).sample

      while @selected_piece.valid_moves.empty?
        @selected_piece = @board.entire_color(@color).sample
      end
    else
      @selected_piece = killer_pieces.sample
    end

    @selected_piece.pos
  end

  def select_destination

    most_harmful = []

    @selected_piece.valid_moves.each do |move|
      most_harmful << move if !@board[move].nil?
    end

    if most_harmful.empty?
      @selected_piece.valid_moves.sample
    else
      most_harmful.sample
    end

  end

end
