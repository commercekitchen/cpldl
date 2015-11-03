$(document).ready(function() {

  sendLessonCompletedEvent = function() {
    Modal.open("lesson-complete-modal");
    $.ajax({
      url: window.location.pathname + "/complete",
      type: "POST",
      dataType: "json"
    }).done(function(data) {
      // TODO: what to do here?
    }).fail(function(data) {
      // TODO: what to do here?
      console.log(data);
    });
  };

});
