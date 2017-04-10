require 'open-uri'
require 'json'

class GameController < ApplicationController
  def index
    letters = generate_grid(10)
    # letters = %w(T E S T E G J)
    @grid = letters.join(" - ")
    @start_time = Time.now.to_f
    @attempts = cookies[:attempts]
  end

  def score
    word = params[:word]
    letters = params[:grid].split(" - ")
    start_time = params[:start_time].to_f
    end_time = Time.now.to_f
    @result = run_game(word, letters, start_time, end_time)
    cookies[:attempts] = cookies[:attempts].to_i + 1
  end

  private

  def delete_cookies
    cookies.delete :user_name
    cookies.delete :customer_number
  end

  def generate_grid(grid_size)
    alphabet = ("A".."Z").to_a
    grid = []
    grid_size.times { grid << alphabet.sample }
    grid
  end

  WORDS = File.read('/usr/share/dict/words').upcase.split("\n")

  def run_game(attempt, grid, start_time, end_time)
    if !validate_letters(attempt, grid)
      { time: end_time - start_time, score: 0, message: "not in the grid" }
    elsif !WORDS.include? attempt.upcase
      { time: end_time - start_time, score: 0, message: "not an english word" }
    else
      { translation: translator(attempt)["outputs"][0]["output"],
        time: end_time - start_time,
        score: (attempt.size * 50) - (end_time - start_time).to_i,
        message: "well done" }
    end
  end

  def translator(w)
    key = "32e295f1-4ba6-4862-ad98-0156028a8d5"
    strio = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}b&input=#{w}")
    JSON.parse(strio.read)
  end

  def validate_letters(attempt, grid)
    attempt_a = attempt.upcase.split("")
    attempt_h = Hash.new(0)
    attempt_a.each { |a| attempt_h[a] += 1 }
    grid_h = Hash.new(0)
    grid.each { |b| grid_h[b] += 1 }
    attempt_h.all? { |k, _v| attempt_h[k] <= grid_h[k] }
    # raise
  end
end
