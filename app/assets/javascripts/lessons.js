$(document).ready(function() {

  sendLessonCompleteEvent = function() {
    var message = "test";
    Modal.open("lesson-complete-modal", message);
    console.log("Sending lesson complete event.")
    $.ajax({
      url: window.location.pathname + "/complete",
      type: "POST",
      dataType: "json"
    }).done(function(data) {
      // window.location = data.next_lesson;
    }).fail(function(data) {
      // TODO: what to do here?
      console.log(data);
    });
  };

});
