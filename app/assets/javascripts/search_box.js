$(document).ready(function() {
  $("#search").focus(function(){
    $(".icon-search").hide();
    $("#search_btn").fadeIn(300);
  });

  $("#search").blur(function(event) {
    $("#search_btn").hide();
    $(".icon-search").fadeIn(300);
  });

  $(".icon-search").click(function() {
    $("#search").focus();
  });
});