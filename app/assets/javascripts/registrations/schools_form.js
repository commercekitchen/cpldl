var schoolsForm = (function () {
  function showForm() {
    $("#school_fields").show();
    $("#user_acting_as").trigger("change");
  }

  function hideForm() {
    $("#school_fields").hide();
    $("#user_student_id").prop("required", false);
  }

  function loadSchoolsByType(schoolType) {
    $.get("/ajax/schools", { school_type: schoolType }).done(function (data) {
      newOptions = data.map(function (obj) {
        return [obj.id, obj.school_name];
      });

      $("#user_school_id").updateDropdown("School", newOptions);
      $("#school_fields .hideUntilActive").show();
    });
  }

  function showStudentFields() {
    $("#student-only").show();
  }

  function hideStudentFields() {
    $("#student-only").hide();
  }

  function makeStudentIdRequired() {
    $("#user_student_id").prop("required", true);
  }

  function makeStudentIdOptional() {
    $("#user_student_id").prop("required", false);
  }

  return {
    showForm: showForm,
    hideForm: hideForm,
    loadSchoolsByType: loadSchoolsByType,
    showStudentFields: showStudentFields,
    hideStudentFields: hideStudentFields,
    makeStudentIdRequired: makeStudentIdRequired,
    makeStudentIdOptional: makeStudentIdOptional,
  };
})();

$(document).ready(function () {
  $("#user_acting_as").change(function (e) {
    var newRole = $(this).val();

    if (newRole == "Student") {
      schoolsForm.showStudentFields();
      schoolsForm.makeStudentIdRequired();
    } else {
      schoolsForm.hideStudentFields();
      schoolsForm.makeStudentIdOptional();
    }
  });

  $("#school_type").change(function () {
    var schoolType = $(this).val();

    if (schoolType !== "") {
      $("#school_type option[value='']").remove();
      schoolsForm.loadSchoolsByType(schoolType);
    }
  });
});
