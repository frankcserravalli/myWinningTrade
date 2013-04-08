$(function() {
  $(".new_group").on("keyup", "#search", function(){

    $(this).parents(".student-search-form").submit();
  });
});
