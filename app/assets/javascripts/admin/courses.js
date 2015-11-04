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

var ready;

ready = function(){
    // call sortable on our div with the sortable class
    $('.sortable').sortable();
}

var ready, set_positions;

set_positions = function(){
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('.panel.panel-default').each(function(i){
        $(this).attr("data-pos",i+1);
    });
}

ready = function(){
  // call set_positions function
  set_positions();

  $('.sortable').sortable();

  // after the order changes
  $('.sortable').sortable().bind('sortupdate', function(e, ui) {
      // array to store new order
      updated_order = []
      // set the updated positions
      set_positions();

      // populate the updated_order array with the new task positions
      $('.sortable-item').each(function(i){
          updated_order.push({ id: $(this).data("id"), position: i+1 });
      });

      // send the updated order via ajax
      $.ajax({
          type: "PUT",
          url: '/admin/courses/sort',
          data: { order: updated_order }
      });
  });
}

$(document).ready(ready);

