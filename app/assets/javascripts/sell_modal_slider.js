$( document ).ready(function() {
	var price = document.getElementById('get-price-2');

	$( ".sell-measure" ).slider({
	  animate: "fast",
	  values: 1,
	  min: 1,
	  max: 2
	});

	$( ".sell-price-target" ).slider({
	  animate: "fast",
	  value: parseFloat(price.dataset.price),
	  min: 0,
	  max: parseFloat(price.dataset.price) + 2000.00,
	  range: true,
	  step: .01
	});

	$( ".sell-measure" ).on( "slidechange", function( event, ui ) {
		var selection = $( ".sell-measure" ).slider( "value" );
		if (selection == 1){
			$('#sell_measure').val('Above');
		}
		else{
			$('#sell_measure').val('Below');
		}
	} );

	$( ".sell-price-target" ).on( "slide", function( event, ui ) {
		var selection = $( ".sell-price-target" ).slider( "value" );
		$('.sell-target-price').text('$'.concat(selection));
		$('#sell_price_target').val(selection);
	} );
});