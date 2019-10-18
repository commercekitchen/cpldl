$(document).ready(function() {
  // NOTE: this method name should not be changed, it must
  // match the event from the ASL file:
  // window.parent.sendLessonCompletedEvent();
  sendLessonCompletedEvent = function() {
    $.ajax({
      url: window.location.pathname + "/complete",
      type: "POST",
      dataType: "json"
    }).always(function(data) {
      if (data.redirect_path) {
        window.location = data.redirect_path;
      }
    });
  };

  getDLCTransition = function(_) {
    sendLessonCompletedEvent();
  };
});
