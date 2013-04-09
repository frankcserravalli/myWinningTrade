$(function() {
  var names = [];

  var add_student_pressed = false;

  // When an user types in a letter in the student name input field
  $(".container").on("keyup", "#search", function(){
    // Here we are submitting the form if the user has inserted more than 3 characters
    // into the student name input field.
    //alert(123);
    $(this).parents(".student-search-form").submit();
  });

});

