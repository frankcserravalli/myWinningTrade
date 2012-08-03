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
//= require bootstrap-button
//= require bootstrap-collapse
//= require chosen-jquery
//= require underscore
//= require moment
//= require rickshaw_with_d3
//= require flash
//= require finance
//= require handlebars-1.0.0.beta.6.js
//= require ember-latest
//= require_self
//= require ember_app
//= require_tree .//rickshaw
//= require_tree .//stock
//= require general

App = Ember.Application.create();

Number.prototype.formatMoney = function(c, d, t){
var n = this, c = isNaN(c = Math.abs(c)) ? 2 : c, d = d == undefined ? "," : d, t = t == undefined ? "." : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
   return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };
