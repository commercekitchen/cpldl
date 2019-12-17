$(document).ready(function() {
  var $el = $(".course-title");
  var height = 75;
  $el.shave(height);
  bindResizeEvent($el, height);
});
