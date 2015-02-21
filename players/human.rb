class HumanPlayer

  attr_reader :color
  attr_accessor :board

  def initialize(board, color, cursor, game)
    @board = board
    @color = color
    @cursor = cursor
    @game = game
  end

  def select_piece
    input_handler("Select your piece...")
  end

  def select_destination
    input_handler("Select your piece's destination...")
  end

  private

    def input_handler(message)
      loop do
        system('clear')
        @board.render(@cursor)
        puts message
        puts "W,A,S,D to move cursor and R to select"
        input = STDIN.getch

        case input
        when 'w'
          @cursor[0] -= 1 unless @cursor[0] == 0
        when 'a'
          @cursor[1] -= 1 unless @cursor[1] == 0
        when 's'
          @cursor[0] += 1 unless @cursor[0] == 7
        when 'd'
          @cursor[1] += 1 unless @cursor[1] == 7
        when 'r'
          break
        when 'q'
          user_input = nil
          until ['Y', 'N'].include?(user_input)
            puts "Do you wish to save your game? (y/n)"
            user_input = gets.chomp.upcase
          end

          @game.save if user_input == 'Y'

          exit
        end
      end

      @cursor.dup
    end

end
