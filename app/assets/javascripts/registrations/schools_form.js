var schoolsForm = (function () {
  function showForm() {
    $("#school_fields").show();
  }

  function resetForm() {}

  function hideForm() {
    $("#school_fields").hide();
  }

  function loadSchoolTypes() {}

  function showStudentFields() {
    $("#student-only").show();
    $("#user_student_id").attr("placeholder", "Student ID #");
  }

  function hideStudentFields() {
    $("#student-only").hide();
    $("#user_student_id").attr("placeholder", "Students' ID #s");
  }

  return {
    showForm: showForm,
    resetForm: resetForm,
    hideForm: hideForm,
    loadSchoolTypes: loadSchoolTypes,
    showStudentFields: showStudentFields,
    hideStudentFields: hideStudentFields,
  };
})();

$(document).ready(function () {
  $("#user_acting_as").change(function (e) {
    var newRole = $(this).val();

    if (newRole == "Student") {
      schoolsForm.showStudentFields();
    } else {
      schoolsForm.hideStudentFields();
    }
  });
});
