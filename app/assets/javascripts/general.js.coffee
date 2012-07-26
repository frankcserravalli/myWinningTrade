$(document).ready ->
  $('.chzn-select').chosen();

  setTimeout ( ->
    $('#flash li').animate { opacity: 0 }, 500, ->
      $(this).slideUp()
   ), 4500