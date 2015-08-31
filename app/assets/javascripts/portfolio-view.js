$( document ).ready(function() {
  $('.first-tab').addClass('secondary-active');
  $('.second').hide();
  $('.third').hide();
  $('.fourth').hide();
  $('.fifth').hide();
  $('.sixth').hide();

    $('.first-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.first-tab').addClass('secondary-active');
      $('.second').hide();
      $('.third').hide();
      $('.fourth').hide();
      $('.fifth').hide();
      $('.sixth').hide();
      $('.first').show();
    });

    $('.second-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.second-tab').addClass('secondary-active');
      $('.first').hide();
      $('.third').hide();
      $('.fourth').hide();
      $('.fifth').hide();
      $('.sixth').hide();
      $('.second').show();
    });

    $('.third-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.third-tab').addClass('secondary-active');
      $('.first').hide();
      $('.second').hide();
      $('.fourth').hide();
      $('.fifth').hide();
      $('.sixth').hide();
      $('.third').show();
    });

    $('.fourth-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.fourth-tab').addClass('secondary-active');
      $('.first').hide();
      $('.second').hide();
      $('.third').hide();
      $('.fifth').hide();
      $('.sixth').hide();
      $('.fourth').show();
    });

    $('.fifth-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.fifth-tab').addClass('secondary-active');
      $('.first').hide();
      $('.second').hide();
      $('.third').hide();
      $('.fourth').hide();
      $('.sixth').hide();
      $('.fifth').show();
    });

    $('.sixth-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.sixth-tab').addClass('secondary-active');
      $('.first').hide();
      $('.second').hide();
      $('.third').hide();
      $('.fourth').hide();
      $('.fifth').hide();
      $('.sixth').show();
    });

    $('.add-credits-button').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.fourth-tab').addClass('secondary-active');
      $('.first').hide();
      $('.second').hide();
      $('.third').hide();
      $('.fifth').hide();
      $('.sixth').hide();
      $('.fourth').show();
    });

    /******* New Methods *************/

    $('.first-market-tab').click(function(){
      $.ajax({
        type: 'GET',
        url: '/popular_market',
        dataType: 'html',
        success: function(data){
          $('#content').html("<div class='widget-container'></div>" + data)
        }
      });
      $('.secondary-active').removeClass('secondary-active');
      $('.first-market-tab').addClass('secondary-active');
    });

    $('.second-market-tab').click(function(){
      $.ajax({
        type: 'GET',
        url: '/nyse_market',
        dataType: 'html',
        success: function(data){
          $('#content').html("<div class='widget-container'></div>" + data)
        }
      });
      $('.secondary-active').removeClass('secondary-active');
      $('.second-market-tab').addClass('secondary-active');
    });

    $('.third-market-tab').click(function(){
      $.ajax({
        type: 'GET',
        url: '/nasdaq_market',
        dataType: 'html',
        success: function(data){
          $('#content').html("<div class='widget-container'></div>" + data)
        }
      });
      $('.secondary-active').removeClass('secondary-active');
      $('.third-market-tab').addClass('secondary-active');
    });

    $('.fourth-market-tab').click(function(){
      $.ajax({
        type: 'GET',
        url: '/top_100',
        dataType: 'html',
        success: function(data){
          $('#content').html("<div class='widget-container'></div>" + data)
        }
      });
      $('.secondary-active').removeClass('secondary-active');
      $('.fourth-market-tab').addClass('secondary-active');
    });
});

function remove_widget(){
  $('.widget-container').removeAttr('id');
  $('.widget-container').removeAttr('id');
  var iframes = document.getElementsByTagName('iframe');
  for (var i = 0; i < iframes.length; i++) {
      iframes[i].parentNode.removeChild(iframes[i]);
  }
}
