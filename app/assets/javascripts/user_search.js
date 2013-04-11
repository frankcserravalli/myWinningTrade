$(function() {

  // Here we are creating some variables for the autocomplete portion of the user search
  var MWT = window.MWT || {};

  MWT.names = [];

  MWT.names_hash = {};

  window.MWT = MWT;

  // When an user types in a letter in the student name input field
  $(".container").on("keyup", "#term", function(){
    // Here we are submitting the form if the user has inserted more than 3 characters
    // into the student name input field.
    $(this).parents(".student-search-form").submit();
  });

  $(".container").on("click", ".add_nested_fields", function() {
    // Grab the text the user submitted in the input box
    var term = $("#term").val();

    // Loop through our associative array of all the names
    for (var name in MWT.names_hash) {

      if (MWT.names_hash[name] === term)
      {
        //Start here, it's not selecting the input field for some reason.
        $(".student-id").addClass("term");
        //console.log($(".student-id").val());
      }
    }
  });
});

