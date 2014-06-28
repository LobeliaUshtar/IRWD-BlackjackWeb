require 'rubygems'
require 'sinatra'

set :sessions, true

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
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end
  session[:player_name] = params[:player_name].capitalize
  redirect '/game'
end

get '/game' do
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @success = "Congrats, #{session[:player_name]} has BLACKJACK!!!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "Sorry, it looks like #{session[:player_name]} busted. Dealer Gabby wins."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay.  Dealer Gabby's turn."
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_or_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == 21
    @error = "Sorry, #{session[:player_name]}, Dealer Gabby hit BLACKJACK."
    @show_hit_or_stay_buttons = false
  elsif dealer_total > 21
    @success = "Congrats, #{session[:player_name]} wins because Dealer Gabby busted."
    @show_hit_or_stay_buttons = false
  elsif dealer_total >= 17
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end
    erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    @error = "Sorry, #{session[:player_name]}, Dealer Gabby wins."
  elsif player_total > dealer_total
    @success = "Congrats, #{session[:player_name]} wins!"
  else
    @success = "It's a tie."
  end
  erb :game
end






