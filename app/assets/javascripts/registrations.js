(function(registrations) {
  registrations(window.jQuery, window, document);
}(function($, window, document) {
    $(function() {

      $("input[type=radio][name=program_type]").change(function(){
        if (this.value !== "none"){
          $("#organization_program.hideUntilActive").show();
          getProgramsOfType(this.value).done(updateProgramSelection);
        } else {
          $("#organization_program.hideUntilActive").hide();
        }
      });

      $("#organization_program").change(function(e){
        var programId = $(this).val();

        if (programId === ""){
          $("#program_location_fields.hideUntilActive").hide();
          $("#school_fields.hideUntilActive").hide();
        } else {
          getNewProgramData(programId).done(updateRegistrationFields);
        }
      });

      $("#user_acting_as").change(function(e){
        var newRole = $(this).val();

        if (newRole == "Student"){
          showStudentFields();
        } else {
          hideStudentFields();
        }
      });

    });


    function getProgramsOfType(type){
      return $.ajax({
        method: "post",
        url: "/ajax/programs/get_sub_programs",
        data: { parent_type: type }
      })
    }

    function updateProgramSelection(data){
      var newOptionsArray = data.map(function(obj){
        return [obj.id, obj.program_name];
      });

      $("#organization_program").updateDropdown("Program", newOptionsArray);
    }

    function getNewProgramData(programId){
      return $.ajax({
        method: "post",
        url: "/ajax/programs/select_program",
        data: { program_id: programId }
      });
    }

    function updateRegistrationFields(data){
      var programType = data.parent_type;
      var programLocations = data.program_locations;

      updateProgramLocationSection(programLocations);
      updateSchoolsSection(programType);
    }

    function showStudentFields(){
      $("#student-only.hideUntilActive").show();
      $("#user_student_id").attr("placeholder", "Student ID #");
    }

    function hideStudentFields(){
      $("#student-only").hide();
      $("#user_student_id").attr("placeholder", "Students' ID #s");
    }

    function updateProgramLocationSection(programLocations){
      if (programLocations.length > 0){
        $("#program_location_fields.hideUntilActive").show();

        var newOptionsArray = programLocations.filter(function(obj){
          return JSON.parse(obj.enabled);
        }).map(function(obj){
          return [obj.id, obj.location_name];
        });

        $("#user_program_location_id").updateDropdown("Location", newOptionsArray);
      } else {
        $("#program_location_fields.hideUntilActive").hide();
      }
    }

    function updateSchoolsSection(programType){
      if (programType == "students_and_parents"){
        $("#school_fields.hideUntilActive").show();
      } else {
        $("#school_fields.hideUntilActive").hide();
      }
    }

  }
));