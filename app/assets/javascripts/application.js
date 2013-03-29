//= require jquery
//= require jquery_ujs
//= require jquery.ui.core
//= require jquery.ui.autocomplete
//= require jquery.ui.slider
//= require jquery.ui.tabs
//= require jquery.html5-placeholder-shim
//= require bootstrap-dropdown
//= require bootstrap-tab
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-modal
//= require bootstrap-button
//= require bootstrap-collapse
//= require bootstrap-modal
//= require bootstrap-transition
//= require chosen-jquery
//= require underscore
//= require moment
//= require flash
//= require finance
//= require submit_form_and_share
//= require stripe
//= require subscription
//= require adsense
//= require ChunkFive_400.font
//= require jquery.easing1.3
//= require cufon-yui
//= require_self
//= require_tree .//stock
//= require general

Number.prototype.formatMoney = function(c, d, t){
var n = this, c = isNaN(c = Math.abs(c)) ? 2 : c, d = d == undefined ? "," : d, t = t == undefined ? "." : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };
