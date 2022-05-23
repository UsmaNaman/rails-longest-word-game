require 'json'
require 'open-uri'

class GamesController < ApplicationController

  def new
    @letters = generate_grid(10).join
  end

  def score
    @letters = params[:letters].split('')
    @attempt = params[:attempt]
    @result = run_game(@attempt, @letters)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, letters)
    guess.split('').all? { |letter| letters.include? letter }
  end

  def compute_score(attempt)
    attempt.size
  end

  def run_game(attempt, letters)
    result = {}
    result[:word] = valid_word(attempt)
    result[:score], result[:message] = score_and_message(attempt, letters, result[:word])
    result
  end

  def score_and_message(attempt, letters, word)
    if word
      if included?(attempt.upcase, letters)
        score = compute_score(attempt)
        [score, 'Well done!']
      else
        [0, 'Word not on the grid.']
      end
    else
      [0, 'Not an English word']
    end
  end

  def valid_word(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['found'] unless json['Error']
  end
end
