$(document).ready(function() {
  // player_area();
  player_hits();
  player_stays();
  // dealer_area();
  dealer_hits();
});

// function player_area() {
//   $('div#player_cards').css('background-color', 'lightgreen');
// }

// function dealer_area() {
//   $('div#dealer_cards').css('background-color', 'lightblue');
// }

function player_hits() {
  $(document).on('click', 'form#hit_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg){
      $('div#game').replaceWith(msg);
    });
    $('div#player_cards').css('background-color', 'lightgreen');
    return false;  
  });
}

function player_stays() {
  $(document).on('click', 'form#stay_form input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg){
      $('div#game').replaceWith(msg);
    });
    $('div#player_cards').css('background-color', 'orange');
    return false;
  });
}

function dealer_hits() {
  $(document).on('click', 'form#dealer_hit input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg){
      $('div#game').replaceWith(msg);
    });
    $('div#dealer_cards').css('background-color', 'lightblue');
    return false;
  });
}