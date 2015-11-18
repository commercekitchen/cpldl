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
});
