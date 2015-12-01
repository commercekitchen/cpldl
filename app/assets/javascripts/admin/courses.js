$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#course_title", function() {
    if($("#course_seo_page_title").val().trim() === "") {
      $("#course_seo_page_title").val($("#course_title").val());
    }
  });

  // If the user enters text in the topics textbox, mark the checkbox too.
  $("body").on("change", "#course_other_topic_text", function() {
    if($(this).val().trim() !== "") {
      $("#course_other_topic").prop("checked", true);
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

  // remove attachment fields in Course form
  $(function () {
    $(document).delegate('.remove_child','click', function() {
      $(this).parent().children('.removable')[0].value = 1;
      $(this).parent().slideUp();
      // $(this).parent().hide();
      return false;
    });
   });

  // add attachment fields in Course form
  function add_fields(association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g")
    $("#add-attachment").parent().before(content.replace(regexp, new_id));
  };
