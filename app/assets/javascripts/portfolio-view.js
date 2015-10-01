var d = Array();
$( document ).ready(function() {
  var template = Handlebars.templates.stocks
  getData('/popular_market', 0);
  getData('/nyse_market', 1);
  getData('/nasdaq_market', 2);
  getData('/top_100', 3);

  $('.dropdown-wrapper').hide();

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
      $('#portfolio-stach').html(template(d[0]));
      $('.secondary-active').removeClass('secondary-active');
      $('.first-market-tab').addClass('secondary-active');
    });

    $('.second-market-tab').click(function(){
      $('#portfolio-stach').html(template(d[1]));
      $('.secondary-active').removeClass('secondary-active');
      $('.second-market-tab').addClass('secondary-active');
    });

    $('.third-market-tab').click(function(){
      $('#portfolio-stach').html(template(d[2]));
      $('.secondary-active').removeClass('secondary-active');
      $('.third-market-tab').addClass('secondary-active');
    });

    $('.fourth-market-tab').click(function(){
      $('#portfolio-stach').html(template(d[3]));
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

function getData(url, index){
  $.ajax({
    type: 'GET',
    url: url,
    dataType: 'json',
    contentType: 'application/json',
    accept: 'application/json',
    success: function(data){
      d[index] = data;
    }
  });
}
