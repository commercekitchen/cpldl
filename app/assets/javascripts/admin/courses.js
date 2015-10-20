$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#course_title", function() {
    if($("#course_seo_page_title").val().trim() === "") {
      $("#course_seo_page_title").val($("#course_title").val());
    }
  });

  $("#course_title").simplyCountable({
    counter: "#course_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
    });

  $("#course_seo_page_title").simplyCountable({
    counter: "#course_seo_page_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
    });

  $("#course_summary").simplyCountable({
    counter: "#course_summary_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
    });

  $("#course_meta_desc").simplyCountable({
    counter: "#course_meta_desc_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
    });
});
