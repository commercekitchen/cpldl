$(document).ready(function() {
  $(".load-on-click").click(function() {
    $(this).hide();
    $(this)
      .parent()
      .find(".loader")
      .show();
  });
});
