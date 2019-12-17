function bindResizeEvent($el, height) {
  $el.on("textresize", function() {
    $el.shave(height);
    $(this).unbind("textresize");
    bindResizeEvent($(this), height);
  });
}
