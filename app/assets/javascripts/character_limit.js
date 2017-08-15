/*
  Simple Character Counter
  Alex Brinkman 2017
*/

var CharacterLimit = (function($) {
  return {
    init: function() {
      $("*[maxlength]").each(updateText);
      $("body").on("keyup", "*[maxlength]", updateText);
    }
  };

  function updateText() {
    var characterLimit = $(this).attr("maxlength");
    var characterCount = $(this).val().length;
    $(this).siblings(".character-limit").text(characterLimit - characterCount + " characters remaining");
  }

})(jQuery);

$(document).ready(function() {
  CharacterLimit.init();
});