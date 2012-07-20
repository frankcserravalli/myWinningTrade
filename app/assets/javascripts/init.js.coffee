$(document).ready ->
  $('.chzn-select').chosen();

  setTimeout ( ->
    $('p.alert').animate { opacity: 0 }, 500, ->
      $(this).slideUp()
   ), 4500
