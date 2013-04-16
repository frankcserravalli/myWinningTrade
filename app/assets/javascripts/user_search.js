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

  $(document).on('nested:fieldRemoved', function(event){

    var field = event.field;

    var inputField = field.find('input:first');

    inputField.val("");

    console.log(inputField.val());

  });

  $(document).on('nested:fieldAdded', function(event){

    var term = $("#term").val();

    for (var name in MWT.names_hash) {

      if (MWT.names_hash[name] === term) {
        //Start here, it's not selecting the input field for some reason.
        //alert(name);

        var field = event.field;

        var inputField = field.find('input:first');

        inputField.val(name);

        inputField.before("<td>" + term + "</td>");

        break
      }
    }

    $("#term").val("");
  });
});

