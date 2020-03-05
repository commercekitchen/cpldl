$(document).ready(function() {
  // NOTE: this method name should not be changed, it must
  // match the event from the ASL file:
  // window.parent.sendLessonCompletedEvent();
  sendLessonCompletedEvent = function() {
    var preview = getUrlParameter("preview");
    var requestUrl = window.location.pathname + "/complete";

    if (preview == "true") {
      requestUrl = requestUrl + "?preview=true";
    }

    $.ajax({
      url: requestUrl,
      type: "POST",
      dataType: "json"
    }).always(function(data) {
      if (data.redirect_path) {
        window.location = data.redirect_path;
      }
    });
  };

  getUrlParameter = function(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
    var results = regex.exec(location.search);
    return results === null
      ? ""
      : decodeURIComponent(results[1].replace(/\+/g, " "));
  };

  getDLCTransition = function(_) {
    sendLessonCompletedEvent();
  };

  handleLessonCompleted = function(event) {
    if (event.data === "lesson_completed") {
      sendLessonCompletedEvent();
    }
  };

  window.addEventListener("message", handleLessonCompleted, true);
});
