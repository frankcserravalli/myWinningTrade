$(document).ready(function() {

  $(".dashboard-tutorial").click(function() {

    alert("Button pressed");

    _t.push({start: 'Dashboard', config:{force:true}});

  });

  $(".trading-tutorial").click(function() {

    _t.push({start: 'Trading', config:{force:true}});

  });

});