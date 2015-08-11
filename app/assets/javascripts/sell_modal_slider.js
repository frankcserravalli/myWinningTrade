$( document ).ready(function() {
	var price = document.getElementById('get-price');

	$( ".sell-measure" ).slider({
	  animate: "fast",
	  values: 1,
	  min: 1,
	  max: 2
	});

	$( ".sell-price-target" ).slider({
	  animate: "fast",
	  value: price.dataset.price,
	  min: 0,
	  max: price.dataset.cash,
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