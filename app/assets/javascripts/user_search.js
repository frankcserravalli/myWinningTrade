$(function() {

  // Here we are creating some variables for the autocomplete portion of the user search
  var MWT = window.MWT || {};

  MWT.names = [];

  MWT.names_hash = {};

  MWT.edit_student_search_field_pressed = false;

  window.MWT = MWT;

  // Document ready
  $(document).ready(function() {
    // This disables the add student button from the start, we can't do it via HTML because that would
    // make things complicated
    $(".add-student-btn").removeClass("add_nested_fields");
  });


  // When an user types in a letter in the student name input field
  $(".container").on("keyup", "#term", function(){
    var term = $("#term").val();

    // Here we are submitting the form if the user has inserted more than 3 characters
    // into the student name input field.
    if (term !== "") {
      // Since the term has some text in it, then we allow the add student button to work by
      // adding the class
      $(".add-student-btn").addClass("add_nested_fields");

      $(this).parents(".student-search-form").submit();
    } else {
      // This prevents adding an empty student
      $(".add-student-btn").removeClass("add_nested_fields");
    }
  });

  $(".container").on('nested:fieldRemoved', function(event){
    var field = event.field;

    var inputField = field.find('input:first');

    inputField.val("");
  });

  $(".container").on("keyup", "edit-student-search-input-field", function() {

    MWT.edit_student_search_field_pressed = true;

  });

  $(".container").on('nested:fieldAdded', function(event){
    var term = $("#term").val();

    for (var name in MWT.names_hash) {
      if (MWT.names_hash[name] === term) {
        //Start here, it's not selecting the input field for some reason.
        //alert(name);

        var field = event.field;

        var inputField = field.find('input:first');

        inputField.val(name);

        if (MWT.edit_student_search_field_pressed === true) {
          inputField.before("<td>" + term + "</td>");
        }

        break
      }
    }

    $("#term").val("");

    $(".add-student-btn").removeClass("add_nested_fields");
  });
});

