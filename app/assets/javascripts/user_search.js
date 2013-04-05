$(function() {
  $(".new_group").on("keypress", ".student-name", function(){

    $(this).parents(".student-search-form").submit();
  });
});
