require 'yaml'

class Game
  attr_reader :word, :guess, :available_letters, :solved_letters, :incorrect_letters, :guesses

  def initialize
    @word = word
    @solved_letters = []
    @available_letters = []
    @incorrect_letters = []
    @guesses = 7

    pick_word
  end

  def game_menu
    puts 'Welcome to a game of Hangman.'
    puts 'You can only have 7 incorrect guesses before you hang the man.'
    puts 'To quit, type "exit" and the game will end.'
    puts 'To save at any point, type "save".'
    puts 'To load game, input "load."'
    puts 'For a new game, just push ENTER.'
    input = gets.chomp.downcase
    SaveFunction.new.load_game if input == 'load'
    play
  end

  def play 
    show_progress
    get_guess
  end

  def pick_word
    word_array = File.readlines('5desk.txt')
    word_array.reject! {|word| word.length < 5 || word.length > 12}
    @word = word_array.sample.downcase.strip
  end

  def get_guess
    puts 'Type your guess below.'
    @guess = gets.chomp.downcase
    analyze_guess
  end

  def analyze_guess
    if @guess == 'exit'
      exit
    elsif @guess == 'save'
      save_file = SaveFunction.new.save_game(self)
    elsif @guess == 'load'
      load_file = SaveFunction.new.load_game
    elsif @guess.match? /\A[a-z]*\z/
      @guess = @guess.chr #to trim if it is longer than 1 character
      if @word.include? @guess
        @solved_letters.push(guess)
      else
        if @incorrect_letters.include? @guess
          puts "You have already guessed that letter!"
        else
        @incorrect_letters.push(guess) 
        @guesses -= 1
        end
      end                                         
    else
      puts "Sorry, not sure what you meant to say. Please try again."
      get_guess
    end
    guesses_left
    game_over?
    play
  end

  private

  def show_progress
    if @solved_letters == []
      @word.split('').each { |n|
          print '_ '
      }
    else
      @word.split('').each { |n|
        if @solved_letters.include? n
          print "#{n} "
        else
          print '_ '
        end
      }
    end
    puts
    puts "Letters you already tried:"
    p @incorrect_letters
  end

  def guesses_left
    puts "You have #{@guesses} left."
  end

  def game_over?
    if @guesses == 0 
      puts "Sorry, game over!"
      puts "the word you were trying to guess was '#{@word}'."
      exit
    end

    word_array = @word.chars

    if word_array.sort.uniq == @solved_letters.sort.uniq
      puts "Congradulations! You won the game with the word '#{@word}'!"
      exit
    end
  end
end

class SaveFunction
  def save_game(current_game)
    puts "Enter name for saved game."
    filename = gets.chomp
    dump = YAML.dump(current_game)
    File.open(File.join(Dir.pwd, "/saved/#{filename}.yaml"), 'w') {|file| file.write dump}
    puts "select a new letter to continue game, or exit to end session."
  end

  def load_game
    filename = choose_game
    saved = File.open(File.join(Dir.pwd, "/saved/#{filename}.yaml"), 'r')
    loaded_game = YAML.load(saved)
    game = loaded_game
    game.play
  end

  def choose_game
    puts "Select which game you would like to load."
    filenames = Dir.glob('saved/*').map {|file| file[(file.index('/') + 1)...(file.index('.'))]}
    puts filenames
    filename = gets.chomp
  end
end

game = Game.new
game.game_menu
