$ ->
  setTimeout ( ->
    $('#flash li').not('.persistent').animate { opacity: 0 }, 500, ->
      $(this).slideUp()
   ), 4500
