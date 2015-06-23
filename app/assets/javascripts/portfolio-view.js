$( document ).ready(function() {
  $('.first-tab').addClass('secondary-active');
  $('.second').hide();
  $('.third').hide();
  $('.fourth').hide();
  $('.fifth').hide();
  $('.sixth').hide();
  $('.stock-info').hide();

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
});

function remove_widget(){
  $('.stock-info').hide();
  $('.widget-container').removeAttr('id');
  $('.widget-container').removeAttr('id');
  var iframes = document.getElementsByTagName('iframe');
  for (var i = 0; i < iframes.length; i++) {
      iframes[i].parentNode.removeChild(iframes[i]);
  }
}