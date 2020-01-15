(function($, window) {
  var interval = 200,
    FALSE = !1,
    CHILD = "tr-child",
    HEIGHT = "tr-height",
    TIMER = "tr-timer";

  var detect = function(element, child) {
    element.data(HEIGHT, child.height());

    return function() {
      if (element.data(HEIGHT) !== child.height()) {
        element.data(HEIGHT, child.height()).triggerHandler("textresize");
      }
    };
  };

  $.event.special.textresize = {
    setup: function() {
      var element = $(this),
        child = $("<span>&nbsp</span>")
          .css({ display: "inline", left: "-9999px", position: "absolute" })
          .appendTo(this == window ? "body" : element),
        timer = window.setInterval(detect(element, child), interval);

      element.data(CHILD, child).data(TIMER, timer);
      return FALSE;
    },
    teardown: function() {
      var element = $(this);

      window.clearInterval(element.data(TIMER));
      element.data(CHILD).remove();
      element
        .removeData(CHILD)
        .removeData(HEIGHT)
        .removeData(TIMER);

      return FALSE;
    }
  };

  $.fn.textresize = function(fn) {
    $(this).bind("textresize", fn);
    return this;
  };
})(jQuery, window);
