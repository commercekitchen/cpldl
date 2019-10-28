$(document).ready(function() {
  var checkBranchesDisplay = function() {
    if ($("#organization_branches").is(":checked")) {
      $("#branch-management").show();
    } else {
      $("#branch-management").hide();
    }
  };

  checkBranchesDisplay();

  $("#organization_branches").change(function() {
    $("#org_branches_form").submit();
    checkBranchesDisplay();
  });
});
