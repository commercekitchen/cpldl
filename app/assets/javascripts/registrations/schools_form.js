var schoolsForm = (function () {
  function showForm() {
    $("#school_fields").show();
  }

  function resetForm() {
    // Clear options
    $("#school_fields hideUntilActive").hide();
  }

  function hideForm() {
    $("#school_fields").hide();
  }

  function loadSchoolsByType(schoolType) {
    $.get("/ajax/schools", { school_type: schoolType }).done(function (data) {
      newOptions = data.map(function (obj) {
        return [obj.id, obj.school_name];
      });

      console.log(newOptions);

      $("#user_school_id").updateDropdown("School", newOptions);
      $("#school_fields .hideUntilActive").show();
    });
  }

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
    loadSchoolsByType: loadSchoolsByType,
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

  $("#school_type").change(function () {
    var schoolType = $(this).val();

    $("#school_type option[value='']").remove();

    schoolsForm.loadSchoolsByType(schoolType);
  });
});
