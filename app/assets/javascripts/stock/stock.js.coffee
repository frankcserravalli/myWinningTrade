$ ->
$(".controls").on "click", "input[data-radio='when-radio']", ->
  type = $(this).data('type')
  val = $(this).val()
  switch val
    when "At Market"
      $("#hidden-"+type+"-later").css "display", "none"
      $("#hidden-"+type+"-stop-loss").css "display", "none"
    when "Future"
      $("#hidden-"+type+"-later").css "display", "inline"
      $("#hidden-"+type+"-stop-loss").css "display", "none"
    when "Stop-Loss"
      $("#hidden-"+type+"-later").css "display", "none"
      $("#hidden-"+type+"-stop-loss").css "display", "inline"