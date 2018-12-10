$(document).ready(function() {
  $("#search").focus(function(){
    $(".icon-search").hide();
    $("#search_btn").fadeIn(300);
  });

  $("#search").blur(function(event) {
    if (!$(this).data("no-blur")) {
      $("#search_btn").hide();
      $(".icon-search").fadeIn(300);
    }
  });

  $("#search_btn").mousedown(function(event) {
    $("#search").data("no-blur", true);
  });

  $(document).mouseup(function(event) {
    if ($("#search").data("no-blur")) {
      $("#search").data("no-blur", false);
      $("#search").trigger("blur");
    }
  });

  $(".icon-search").click(function() {
    $("#search").focus();
  });
});