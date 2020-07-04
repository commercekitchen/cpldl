(function (registrations) {
  registrations(window.jQuery, window, document);
})(function ($, window, document) {
  $(function () {
    $(document).ready(function () {
      var programType = $(
        "input[type=radio][name=program_type][checked='checked']"
      ).val();

      if (programType) {
        programTypeSelected(programType);
      }
    });

    $("input[type=radio][name=program_type]").change(function () {
      programTypeSelected(this.value);
    });

    $("#user_program_id").change(function (e) {
      var programId = $(this).val();
      $("#previously_selected_program").val(programId);
      programSelected(programId);
    });

    $("#user_program_location_id").change(function () {
      var locationId = $(this).val();
      $("#user_previous_location_id").val(locationId);
    });

    $("#chzn").change(function (e) {
      var selection = $(this).val();

      if (selection) {
        $("#custom_branch_name").val("");
        $("#custom_branch_form").hide();
      } else {
        $("#custom_branch_form").show();
      }
    });
  });

  function programTypeSelected(programType) {
    if (programType == "none") {
      $("#user_program_id").val(null);
      $("#user_program_location_id").val(null);
      $(".hideUntilActive").hide();
    } else {
      $("#user_program_id.hideUntilActive").show();
      updateProgramOptions(programType);
    }

    $("#program_location_fields.hideUntilActive").hide();

    if (programType == "students_and_parents") {
      schoolsForm.showForm();
    } else {
      schoolsForm.hideForm();
    }
  }

  function programSelected(id) {
    if (id === "") {
      $("#program_location_fields.hideUntilActive").hide();
      schoolsForm.hideForm();
    } else {
      $.ajax({
        method: "post",
        url: "/ajax/programs/select_program",
        data: { program_id: id },
      }).done(function (response) {
        updateProgramLocationSection(response.program_locations);
      });
    }
  }

  function updateProgramOptions(type) {
    $.ajax({
      method: "post",
      url: "/ajax/programs/sub_programs",
      data: { parent_type: type },
    }).done(function (data) {
      var newOptionsArray = data.map(function (obj) {
        return [obj.id, obj.program_name];
      });

      $("#user_program_id").updateDropdown("Program", newOptionsArray);

      if (newOptionsArray.length === 1) {
        $("#user_program_id option")
          .filter(function () {
            return (
              !this.value ||
              $.trim(this.value).length == 0 ||
              $.trim(this.text).length == 0
            );
          })
          .remove();
      }

      tryPreviousProgramSelection();
    });
  }

  function updateProgramLocationSection(programLocations) {
    var enabledLocations = programLocations.filter(function (obj) {
      return JSON.parse(obj.enabled);
    });

    if (enabledLocations.length > 0) {
      $("#program_location_fields.hideUntilActive").show();

      var newOptionsArray = enabledLocations.map(function (obj) {
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
});
