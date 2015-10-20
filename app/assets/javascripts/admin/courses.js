$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#course_title", function() {
    if($("#course_seo_page_title").val().trim() === "") {
      $("#course_seo_page_title").val($("#course_title").val());
    }
  });

  $("#course_title").simplyCountable({
    counter: "#title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
    });

  $("#course_seo_page_title").simplyCountable({
    counter: "#seo_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
    });

  $("#summary_text").simplyCountable({
    counter: "#summary_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
    });

  $("#meta_text").simplyCountable({
    counter: "#meta_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
    });
});
