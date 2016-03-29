$(document).ready(function() {
  $(".user_role").on("change", function(){ //listen for a change on the given selector(id)
    var userId = $(this).data("userId");
    var value = $(this).val();
    var r = confirm("Are you sure you want to change the role for this user? Changing roles may add or remove priviledges.");

    if(r == true){
      $.ajax({
        url: "/admin/users/" + userId + "/change_user_roles/",
        data: { "value": value },
        dataType: "json",
        type: "PATCH"
      });
    } else {
      location.reload(true);
    }
  });
});


$(function() {
  $("#modal").on("change", function() {
    if ($(this).is(":checked")) {
      $("body").addClass("modal-open");
    } else {
      $("body").removeClass("modal-open");
    }
  });

  $(".modal-fade-screen, .modal-close").on("click", function() {
    $(".modal-state:checked").prop("checked", false).change();
  });

  $(".modal-inner").on("click", function(e) {
    e.stopPropagation();
  });
});
