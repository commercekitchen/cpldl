$(document).ready(function() {
  var $el = $(".shaveable");

  if ($el.length) {
    var height = $el.data("resize-height");
    $el.shave(height);

    $(window).on("textresize", function() {
      $el.shave(height);
    });
  }
});
