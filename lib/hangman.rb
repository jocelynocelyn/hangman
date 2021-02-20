class Game
  attr_reader :word, :guess, :available_letters, :solved_letters, :incorrect_letters, :guesses

  def initialize
    @word = word
    @solved_letters = []
    @available_letters = []
    @incorrect_letters = []
    @guesses = 7
    puts 'Welcome to a game of Hangman.'
    puts 'You can only have 7 incorrect guesses before you hang the man.'
    puts 'To quit, type "exit" and the game will end.'
    puts 'To save at any point, type "save".'
    pick_word
  end

  def play 
    show_progress
    get_guess
  end

  def pick_word
    word_array = File.readlines('5desk.txt')
    word_array.reject! {|word| word.length < 5 || word.length > 12}
    @word = word_array.sample.downcase.strip
    p word
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
      #do something to save the game 
    elsif @guess.match? /\A[a-z]*\z/
      @guess = @guess.chr #to trim if it is longer than 1 character
      if @word.include? @guess
        @solved_letters.push(guess)
      else
        @incorrect_letters.push(guess) 
        @guesses -= 1
      end                                         
    else
      puts "Sorry, not sure what you meant to say. Please try again."
      get_guess
    end
    guesses_left
    game_over?
    play
  end

  def save_game
  end

  def load_game
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

    if word_array.sort.uniq == @solved_letters.sort
      puts "Congradulations! You won the game with the word '#{@word}'!"
      exit
    end
  end
end

game = Game.new
game.play