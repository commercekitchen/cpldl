$(document).ready(function() {
  var $el = $(".lesson-title");
  var height = 50;
  $el.shave(height);
  bindResizeEvent($el, height);
});
