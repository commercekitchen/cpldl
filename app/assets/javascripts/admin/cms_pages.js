$(document).ready(function() {

  // If the seo title is empty, prepopulate with title value.
  $("body").on("blur", "#cms_page_title", function() {
    if($("#cms_page_seo_page_title").val().trim() === "") {
      $("#cms_page_seo_page_title").val($("#cms_page_title").val());
    }
  });

  // Add character counts to form values (title, seo, meta)
  $("#cms_page_title").simplyCountable({
    counter: "#cms_page_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
  });

  $("#cms_page_seo_page_title").simplyCountable({
    counter: "#cms_page_seo_page_title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
  });

  $("#cms_page_meta_desc").simplyCountable({
    counter: "#cms_page_meta_desc_counter",
    countable: "characters",
    maxCount: 156,
    strictMax: true,
    countDirection: "down"
  });

  $(".page_pub").on("change", function(){ //listen for a change on the given selector(id)
    var pageId = $(this).data("pageId");
    var value = $(this).val();
    $.ajax({
      url: "/admin/cms_pages/" + pageId + "/update_pub_status/",
      data: { "value": value },
      dataType: "json",
      type: "PATCH"
    });
  });

});
