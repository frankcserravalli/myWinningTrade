$(document).ready(function() {
  $('.submit-the-sell-and-share-via-fb').on('click', function(e){
    e.preventDefault();

    var input = $("<input>").attr("type", "hidden").attr("name", "soc_network").val("facebook");

    $('#sell_form').append($(input));

    $('#sell_form').submit();
  });

  $('.submit-the-sell-and-share-via-li').on('click', function(e){
    e.preventDefault();

    var input = $("<input>").attr("type", "hidden").attr("name", "soc_network").val("linkedin");

    $('#sell_form').append($(input));

    $('#sell_form').submit();
  });

  $('.submit-the-buy-and-share-via-fb').on('click', function(e){
    e.preventDefault();

    var input = $("<input>").attr("type", "hidden").attr("name", "soc_network").val("facebook");

    $('#buy_form').append($(input));

    $('#buy_form').submit();
  });

  $('.submit-the-buy-and-share-via-li').on('click', function(e){
    e.preventDefault();

    var input = $("<input>").attr("type", "hidden").attr("name", "soc_network").val("linkedin");

    $('#buy_form').append($(input));

    $('#buy_form').submit();
  });
});