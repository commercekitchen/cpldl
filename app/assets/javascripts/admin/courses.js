$(document).ready(function() {
  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#course_title", function() {
    if (
      $("#course_seo_page_title")
        .val()
        .trim() === ""
    ) {
      $("#course_seo_page_title").val($("#course_title").val());
    }
  });

  $(".no_drag_link").on("mousedown", function(e) {
    $(this).trigger("mouseup");
    return false;
  });

  // Only show other topic input if box is checked
  $("#course_other_topic").on("change", function() {
    if ($("#course_other_topic").prop("checked")) {
      $(".topic-box")
        .show()
        .prop("required", true);
    } else {
      $(".topic-box")
        .val("")
        .hide()
        .prop("required", false);
    }
  });

  $(".course_pub").on("change", function() {
    //listen for a change on the given selector(id)
    var courseId = $(this).data("courseId");
    var value = $(this).val();
    if (value == "A") {
      var r = confirm(
        "Are you sure you want to Archive this item? Archiving means it will no longer be avaliable to edit or view."
      );
    } else {
      var r = true;
    }

    if (r == true) {
      $.ajax({
        url: "/admin/courses/" + courseId + "/update_pub_status/",
        data: { value: value },
        dataType: "json",
        type: "PATCH"
      });
    } else {
      location.reload(true);
    }
  });

  $("#course_pub_status").change(function() {
    var value = $(this).val();
    var currentStatus = $(this).data("status");

    if (value == "A") {
      var rconfirm = confirm(
        "Are you sure you want to Archive this item? Archiving means it will no longer be avaliable to edit or view."
      );

      if (rconfirm == false) {
        $("#course_pub_status").val(currentStatus);
        return false;
      }
    }
  });

  $("#course_category_id").change(function() {
    var value = $(this).val();
    var $el = $("#course_category_attributes_name");

    if (value == "0") {
      $el.show();
    } else {
      $el
        .val("")
        .hide()
        .parent()
        .removeClass("field_with_errors");
    }
  });

  if ($("#course_category_id").val() == "0") {
    $("#course_category_attributes_name").show();
  }
});

// remove attachment fields in Course form
$(function() {
  $(document).delegate(".remove_child", "click", function() {
    $(this)
      .parent()
      .children(".removable")[0].value = 1;
    $(this)
      .prev()
      .slideUp();
    $(this)
      .parent()
      .slideUp();
    $(this).slideUp();
    return false;
  });
});

// add attachment fields in Course form
function add_fields(association, content, prefix) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $("#add-attachment-" + prefix).before(content.replace(regexp, new_id));
}
