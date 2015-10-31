var Modal = (function($) {

  return {

    // Both parameters are optional.  Msg should be a string, metadata should be a json object.
    open : function(modal_id) {
      $(".modal-state:checked").prop("checked", false).change();
      $("#" + modal_id).prop("checked", true).change();
      $("body").addClass("modal-open");

      $(".modal-fade-screen, .modal-close").on("click", function() {
        $(".modal-state:checked").prop("checked", false).change();
        $("body").removeClass("modal-open");
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
