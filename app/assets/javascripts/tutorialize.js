// Some variables we create to remember the fact the user already pressed the tutorial button
var pressed_already = false;

$(document).ready(function() {
  $(".dashboard-tutorial").click(function() {
    if (pressed_already === false) {
      _t.push({start: 'Dashboard', config:{force:true}});

      pressed_already = true;
    };

  });

  $(".trading-tutorial").click(function() {
    if (pressed_already === false) {
      _t.push({start: 'Trading', config:{force:true}});

      pressed_already = true;
    };

  });
});