$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#lesson_title", function() {
    if($("#lesson_seo_page_title").val().trim() === "") {
      $("#lesson_seo_page_title").val($("#lesson_title").val());
    }
  });
});
