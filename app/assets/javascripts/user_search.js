$(function() {
  $(".new_group").on("keyup", ".student-name", function(){
    $(this).parents(".student-search-form").submit();
  });
});
