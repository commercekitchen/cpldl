$(document).ready(function() {

  sendLessonCompleteEvent = function() {
    // Modal.close();
    console.log("Sending lesson complete event.")
    $.ajax({
      url: window.location.pathname + "/complete",
      type: "POST",
      dataType: "json"
    }).done(function(data) {
      window.location = data.next_lesson;
    }).fail(function(data) {
      // TODO: what to do here?
      console.log(data);
    });

  };

});
