require 'io/console'
require 'yaml'
class Hangman
  attr_accessor :slots, :try, :used_chr, :word, :max_tries, :victory

  def initialize(round_max = 8)
    @slots = []
    @try = 0
    @used_chrs = []
    @word = ''
    @max_tries = round_max
    @victory = false
    choose_game
  end

  def choose_game #request 1 for load and 2 for new game
    if File.exists?("files/savefile.txt")
      puts 'Welocome to Hangman! Press 1 to load or 2 for new game.'
      input = STDIN.getch
      exit(1) if input == "\u0003"
      input = input.to_i
      if input == 1
        load_game
      else
        new_game
      end
    else
      puts 'Welcome to Hangman! Press any key to begin.'
      input = STDIN.getch
      exit(1) if input == "\u0003"
      new_game
    end
  end

  def new_game
    system 'clear' or system 'cls'
    @slots = []
    @try = 0
    @used_chrs = []
    @word = ''
    @victory = false

    dictionary =  File.open('files/5desk.txt', 'r'){ |file| file.readlines }
    @word = dictionary.select{|w| w.length >= 5 || w.length <= 12}.sample.downcase.strip
    word.length.times{ @slots << "_"}
    play_game
  end

  def save_game
    yml_string = YAML.dump({
      slots: @slots,
      try: @try,
      used_chrs: @used_chrs,
      word: @word,
      max_tries: @max_tries
    })
    File.delete('files/savefile.txt') if File.exists?('files/savefile.txt')
    File.open('files/savefile.txt', 'w'){|file| file.puts(yml_string)}
  end

  def load_game
    yml_string = File.open('files/savefile.txt', 'r'){|file| file.read}
    data = YAML.load(yml_string)
    @slots = data[:slots]
    @try = data[:try]
    @used_chrs = data[:used_chrs]
    @word = data[:word]
    @max_tries = data[:max_tries]
    play_game
  end

  def play_game
    while (@try < @max_tries && !@victory)
      play_round
    end
    end_game
  end

  def end_game
    system 'clear' or system 'cls'
    puts 'The game is over!'
    puts "You have #{@victory ? 'won!' : 'lost'}"
    puts "The word was #{@word}"
    puts 'Press any key for new game, press 1 to quit'
    input = STDIN.getch
    if input == "\u0003" || input == '1'
      exit(1)
    end
      new_game
  end

  def play_round
    correct = false
    system 'clear' or system 'cls'
    puts slots.join(" ")
    puts "_______________________"
    puts "Tries: #{@try} / #{@max_tries}"
    puts "Used word letters: #{@used_chrs.join(" ")}"
    puts 'Input a character, press 1 to save the game, or Ctrl+C to quit'
    
    input = STDIN.getch
    exit(1) if input == "\u0003"

    if input.to_i == 1
      save_game
      puts "saved!"
      sleep 1.5
    elsif input.match(/[a-zA-Z]/)
      input.downcase!
      if @used_chrs.include?(input)
        return
      end
      @word.each_char.with_index do |char, index|
        if char.eql? input
          @slots[index] = char
          correct = true
        end
        @used_chrs << input unless @used_chrs.include?(input)
      end
    end
    @try += 1 unless correct

    if @slots.join("").eql? @word
      @victory = true
    end
  end
end

h = Hangman.new