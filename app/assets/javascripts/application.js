//= require jquery
//= require jquery_ujs
//= require jquery.ui.core
//= require jquery.ui.autocomplete
//= require jquery.ui.slider
//= require jquery.knob.min
//= require jquery.ui.tabs
//= require jquery.ui.datepicker
//= require jquery.html5-placeholder-shim
//= require bootstrap-sprockets
//= require chosen-jquery
//= require underscore
//= require moment
//= require flash

//= require view
//= require portfolio-view
//= require main_nav
//= require buy_form
//= require sell_form

//= require hammer.min
//= require moment
//= require KitKatClock.min
//= require jquery.datetimepicker
//= require clock
//= require sell_clock
//= require modal_slider

//= require sell_modal_slider
//= require finance
//= require submit_form_and_share
//= require stripe
//= require subscription
//= require adsense
//= require test
//= require jquery_nested_form
//= require user_search
//= require tutorialize
//= require_tree .//stock
//= require_self


Number.prototype.formatMoney = function(c, d, t){
var n = this, c = isNaN(c = Math.abs(c)) ? 2 : c, d = d == undefined ? "," : d, t = t == undefined ? "." : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };
