$(document).ready(function() {

  $("#title_text").simplyCountable({
    counter: "#title_counter",
    countable: "characters",
    maxCount: 90,
    strictMax: true,
    countDirection: "down"
    });

  $("#seo_text").simplyCountable({
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
