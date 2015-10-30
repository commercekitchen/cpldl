var Modal = (function($) {

  return {

    // Both parameters are optional.  Msg should be a string, metadata should be a json object.
    open : function(modal_id, msg) {
      $(".modal-state:checked").prop("checked", false).change();
      $("#" + modal_id).prop("checked", true).change();
      $("body").addClass("modal-open");

      if (msg) {
        // TODO: No textarea right now, but lesson data.
        // $(".modal textarea").val(msg);
      }

      $(".modal-fade-screen, .modal-close").on("click", function() {
        $(".modal-state:checked").prop("checked", false).change();
        $("body").removeClass("modal-open");
        location.reload();
      });

      $(".modal-inner").on("click", function(e) {
        e.stopPropagation();
      });
    },

    close : function() {
      $(".modal-state:checked").prop("checked", false).change();
      $("body").removeClass("modal-open");
    }
  }

})(jQuery);
