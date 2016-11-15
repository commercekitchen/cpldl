(function(registrations) {
  registrations(window.jQuery, window, document);
}(function($, window, document) {
    $(function() {

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

    function getNewProgramData(programId){
      return $.ajax({
        method: "post",
        url: "/ajax/programs/select_program",
        data: { program_id: programId }
      });
    }

    function updateRegistrationFields(data){
      var studentProgram = JSON.parse(data.student_program);
      var programLocations = data.program_locations;
      var locationFieldName = data.location_field_name;

      updateProgramLocationSection(programLocations, locationFieldName);
      updateSchoolsSection(studentProgram);
    }

    function showStudentFields(){
      $("#student-only.hideUntilActive").show();
      $("#user_student_id").attr("placeholder", "Student ID #");
    }

    function hideStudentFields(){
      $("#student-only").hide();
      $("#user_student_id").attr("placeholder", "Students' ID #s");
    }

    function updateProgramLocationSection(programLocations, locationFieldName){
      if (programLocations.length > 0){
        $("#program_location_fields.hideUntilActive").show();

        var newOptionsArray = programLocations.filter(function(obj){
          return JSON.parse(obj.enabled);
        }).map(function(obj){
          return [obj.id, obj.location_name];
        });

        $("#user_program_location_id").updateDropdown(locationFieldName, newOptionsArray);
      } else {
        $("#program_location_fields.hideUntilActive").hide();
      }
    }

    function updateSchoolsSection(studentProgram, organizationId){
      if (studentProgram){
        $("#school_fields.hideUntilActive").show();
      } else {
        $("#school_fields.hideUntilActive").hide();
      }
    }

  }
));