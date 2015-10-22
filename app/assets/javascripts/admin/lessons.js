$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#lesson_title", function() {
    if($("#lesson_seo_page_title").val().trim() === "") {
      $("#lesson_seo_page_title").val($("#lesson_title").val());
    }
  });

  $("#lesson_title").simplyCountable({
    counter: "#lesson_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
  });

  $("#lesson_summary").simplyCountable({
    counter: "#lesson_summary_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
  });

  $("#lesson_seo_page_title").simplyCountable({
    counter: "#lesson_seo_page_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
  });

  $("#lesson_meta_desc").simplyCountable({
    counter: "#lesson_meta_desc_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
  });
});
