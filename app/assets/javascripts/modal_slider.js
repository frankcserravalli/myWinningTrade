$( document ).ready(function() {
	var price = document.getElementById('get-price-1');

	$('#buy_measure').val('Above');

	$( ".measure" ).slider({
	  animate: "fast",
	  values: 1,
	  min: 1,
	  max: 2
	});

	$( ".price-target" ).slider({
	  animate: "fast",
	  value: parseInt(price.dataset.price),
	  min: 0,
	  max: parseInt(price.dataset.price) + 2000,
	  range: true,
	  step: .01
	});

	$( ".measure" ).on( "slidechange", function( event, ui ) {
		var selection = $( ".measure" ).slider( "value" );
		if (selection == 1){
			$('#buy_measure').val('Above');
		}
		else{
			$('#buy_measure').val('Below');
		}
	} );

	$( ".price-target" ).on( "slide", function( event, ui ) {
		var selection = $( ".price-target" ).slider( "value" );
		$('.target-price').text('$'.concat(selection));
		$('#buy_price_target').val(selection);
	} );
});