require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_HIT_MIN = 17
INITIAL_POT_AMOUNT = 1000

helpers do
  def calculate_total(cards)
    hand = cards.map { |card| card[1]}

    total = 0
    hand.each do |c|
      if c == 'A'
        total += 11
      else total += c.to_i == 0 ? 10 : c.to_i
      end
    end

    hand.select { |card| card == 'A' }.count.times do
      break if total <=21
      total -= 10
    end

    total
  end

  def card_image(card)
    suit = case card[0]
      when 'C' then 'club'
      when 'D' then 'diamond'
      when 'H' then 'heart'
      when 'S' then 'spade'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner(msg='')
    @play_again = true
    session[:player_pot] = session[:player_pot] + session[:player_bet]
    @winner = "<strong>#{session[:player_name]} wins</strong> ... #{msg}"
    @show_hit_or_stay_buttons = false
    session[:turn] = "dealer"
  end

  def loser(msg='')
    @play_again = true
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @loser = "<strong>#{session[:player_name]} loses</strong> ... #{msg}"
    @show_hit_or_stay_buttons = false
    session[:turn] = "dealer"
  end

  def tie
    @play_again = true
    @tie = "<strong>It's a tie.</strong>"
    @show_hit_or_stay_buttons = false
    session[:turn] = "dealer"
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/clear_session' do
  session[:player_name] = nil
  redirect '/'
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end
  session[:player_name] = params[:player_name].capitalize
  redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i <= 0
    @error = "Must make a bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Must bet equal to or below $#{session[:player_pot]}"
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
  end

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner("#{session[:player_name]} hit BLACKJACK!!!")
  elsif player_total > BLACKJACK_AMOUNT
    loser("#{session[:player_name]} BUSTED with a #{player_total}.")
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner("#{session[:player_name]} hit BLACKJACK!!!")
  elsif player_total > BLACKJACK_AMOUNT
    loser("#{session[:player_name]} BUSTED with a #{player_total}.")
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser("Dealer Gabby hit BLACKJACK!!!")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner("Dealer Gabby BUSTED with a #{dealer_total}")
  elsif dealer_total >= DEALER_HIT_MIN
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
    erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser("#{dealer_total} versus #{player_total}")
  elsif player_total > dealer_total
    winner("#{dealer_total} versus #{player_total}")
  else
    tie
  end
  erb :game, layout: false
end

get '/game_over' do
  erb :game_over
end