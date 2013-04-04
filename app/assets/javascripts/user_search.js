$(function() {
  $(".new_group").on("keyup", ".student-name", function(){

    $(this).submit(function() {
      return false;

      alert("asdf");
      $('#account_settings').on('ajax:success', function(event, xhr, status) {
        $(".student-search-results").append(xhr.responseText)
      });
    });
  });
});



   /*

    //alert($(this).serialize());
    $.get("/search_students", $(this).serialize(), null, "script");
    });
     */