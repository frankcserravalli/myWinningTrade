$(function() {
  // When an user types in a letter in the student name input field
  $(".new_group").on("keyup", "#search", function(){
    // Here we are submitting the form if the user has inserted more than 3 characters
    // into the student name input field.
    $(this).parents(".student-search-form").submit();
  });

  names = [];

  // Here I'm setting up the autocomplete function for student searches
  $( "#search" ).autocomplete({
    source : names,
    width: 300,
    max: 10,
    delay: 100
  });
});


