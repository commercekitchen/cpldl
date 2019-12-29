$(document).ready(function() {
  $(".load-on-click").click(function() {
    $(this).hide();
    $(this)
      .parent()
      .find(".loader")
      .css("display", "inline-block");
  });
});

$(document).ready(function() {
  $(".loading-button").click(function() {
    $(this)
      .find(".loader-label")
      .hide();
    $(this)
      .find(".loader")
      .css("display", "inline-block");
  });
});
