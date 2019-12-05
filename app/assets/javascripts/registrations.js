(function(registrations) {
  registrations(window.jQuery, window, document);
})(function($, window, document) {
  $(function() {
    $(document).ready(function() {
      var programType = $(
        "input[type=radio][name=program_type][checked='checked']"
      ).val();
      if (programType) {
        updateVisibleInputs(programType);
      }
    });

    $("input[type=radio][name=program_type]").change(function() {
      updateVisibleInputs(this.value);
    });

    $("#user_program_id").change(function(e) {
      var programId = $(this).val();
      $("#previously_selected_program").val(programId);
      programSelected(programId);
    });

    $("#user_program_location_id").change(function() {
      var locationId = $(this).val();
      $("#user_previous_location_id").val(locationId);
    });

    $("#user_acting_as").change(function(e) {
      var newRole = $(this).val();

      if (newRole == "Student") {
        showStudentFields();
      } else {
        hideStudentFields();
      }
    });

    $("#chzn").change(function(e) {
      var selection = $(this).val();

      if (selection) {
        $("#custom_branch_name").val("");
        $("#custom_branch_form").hide();
      } else {
        $("#custom_branch_form").show();
      }
    });
  });

  function updateVisibleInputs(programType) {
    if (programType !== "none") {
      $("#user_program_id.hideUntilActive").show();
      getProgramsOfType(programType).done(updateProgramSelection);
    } else {
      $("#user_program_id").val(null);
      $("#user_program_location_id").val(null);
      $(".hideUntilActive").hide();
    }
    $("#program_location_fields.hideUntilActive").hide();
    updateSchoolsSection(programType);
  }

  function tryPreviousProgramSelection() {
    var programId = $("#previously_selected_program").val();
    if (!programId) {
      return;
    }
    if (
      $("#user_program_id").find("option[value=" + programId + "]").length > 0
    ) {
      $("#user_program_id").val(programId);
      programSelected(programId);
    }
  }

  function tryPreviousLocationSelection() {
    var previousId = $("#user_previous_location_id").val();
    if (!previousId) {
      return;
    }
    if (
      $("#user_program_location_id").find("option[value=" + previousId + "]")
        .length > 0
    ) {
      $("#user_program_location_id").val(previousId);
    }
  }

  function programSelected(id) {
    if (id === "") {
      $("#program_location_fields.hideUntilActive").hide();
      $("#school_fields.hideUntilActive").hide();
    } else {
      getNewProgramData(id).done(updateRegistrationFields);
    }
  }

  function getProgramsOfType(type) {
    return $.ajax({
      method: "post",
      url: "/ajax/programs/sub_programs",
      data: { parent_type: type }
    });
  }

  function updateProgramSelection(data) {
    var newOptionsArray = data.map(function(obj) {
      return [obj.id, obj.program_name];
    });

    $("#user_program_id").updateDropdown("Program", newOptionsArray);

    tryPreviousProgramSelection();
  }

  function getNewProgramData(programId) {
    return $.ajax({
      method: "post",
      url: "/ajax/programs/select_program",
      data: { program_id: programId }
    });
  }

  function updateRegistrationFields(data) {
    var programType = data.parent_type;
    var programLocations = data.program_locations;

    updateProgramLocationSection(programLocations);
    updateSchoolsSection(programType);
  }

  function showStudentFields() {
    $("#student-only.hideUntilActive").show();
    $("#user_student_id").attr("placeholder", "Student ID #");
  }

  function hideStudentFields() {
    $("#student-only").hide();
    $("#user_student_id").attr("placeholder", "Students' ID #s");
  }

  function updateProgramLocationSection(programLocations) {
    if (programLocations.length > 0) {
      $("#program_location_fields.hideUntilActive").show();

      var newOptionsArray = programLocations
        .filter(function(obj) {
          return JSON.parse(obj.enabled);
        })
        .map(function(obj) {
          return [obj.id, obj.location_name];
        });

      $("#user_program_location_id").updateDropdown(
        "Location",
        newOptionsArray
      );
      tryPreviousLocationSelection();
    } else {
      $("#program_location_fields.hideUntilActive").hide();
    }
  }

  function updateSchoolsSection(programType) {
    if (programType == "students_and_parents") {
      $("#school_fields.hideUntilActive").show();
    } else {
      $("#school_fields.hideUntilActive").hide();
    }
  }
});
