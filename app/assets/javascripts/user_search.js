$(function() {

  var MWT = window.MWT || {};

  MWT.names = [];

  MWT.names_hash = {};

  window.MWT = MWT;

  // When an user types in a letter in the student name input field
  $(".container").on("keyup", "#term", function(){
    // Here we are submitting the form if the user has inserted more than 3 characters
    // into the student name input field.
    //alert(123);
    $(this).parents(".student-search-form").submit();
  });

  $(".container").on("click", ".add_nested_fields", function() {
    var term = $("#term").val();

    for (var name in MWT.names_hash) {
      //console.log(term);
      if (MWT.names_hash[name] === term)
      {
        //Start here, it's not selecting the input field for some reason.
        $(".student-id:last").addClass('boomboom');

      }
    }
  });
});

