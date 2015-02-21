require 'yaml'
require 'io/console'
require 'colorize'

require './pieces/pieces.rb'
require './board.rb'
require './players/players.rb'

class Chess

  def self.human_v_human
    Chess.new(Human.new, Human.new).run
  end

  def initialize
    @board = Board.new
    @cursor = [0, 0]
    @human = HumanPlayer.new(@board, 'w', @cursor, self)
    @computer = ComputerPlayer.new(@board, 'b')
    @current_player = @human
  end

  def run
    new_or_load
    until game_over?
      system('clear')
      @board.render(@cursor)
      begin
        start_pos = @current_player.select_piece
        end_pos = @current_player.select_destination
        @board.move(start_pos, end_pos, @current_player.color)
      rescue NilPieceError => e
        puts "Error: #{e.message}... hit any key to continue"
        STDIN.getch
        retry
      rescue InvalidMoveError => e
        puts "Error: #{e.message}... hit any key to continue"
        STDIN.getch
        retry
      rescue WrongPieceError => e
        puts "Error: #{e.message}... hit any key to continue"
        STDIN.getch
        retry
      end
      @board.handle_promotions
      @current_player = @current_player == @human ? @computer : @human
    end

    puts "White has won!" if @board.checkmate?('b')
    puts "Black has won!" if @board.checkmate?('w')
  end

  def save
    to_save = @board.to_yaml
    File.open("savegame.yml", "w") do |f|
      f.puts(to_save)
    end
  end

  protected

    def load
      if File.exists?('savegame.yml')
        @board = YAML.load_file('savegame.yml')
        @human.board = @board
        @computer.board = @board
      else
        puts "No save game exists! Press any key to continue."
        STDIN.getch
      end
    end

    def new_or_load
      input = nil
      until ['L', 'N'].include?(input)
        puts "Do you wish to load your last game or start new? (l or n)"
        input = gets.chomp.upcase
      end

      load if input == 'L'
    end

    def game_over?
      @board.checkmate?('w') || @board.checkmate?('b')
    end

end

if __FILE__ == $0

  Chess.new.run

end
