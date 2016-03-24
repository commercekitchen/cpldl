$(document).ready(function() {

  // NOTE: this method name should not be changed, it must
  // match the event from the ASL file:
  // window.parent.sendLessonCompletedEvent();
  sendLessonCompletedEvent = function() {
    var is_assessment = $("#is_assessment").val() == "true";
    if (!is_assessment) {
      window.location = (window.location.pathname + "/lesson_complete")
    }
    $.ajax({
      url: window.location.pathname + "/complete",
      type: "POST",
      dataType: "json"
    }).always(function(data) {
      if (data.complete) {
        window.location = data.complete;
      }
    });
  };

});
