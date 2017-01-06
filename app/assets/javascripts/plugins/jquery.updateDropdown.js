/*
* jQuery Update Dropdown plugin
* Allows a select tag's options to be updated with  new options
*
* @author   Tom Reis (tom@commercekitchen.com)
*
*/

;(function($){

  $.fn.extend({

    updateDropdown: function(defaultOption, newOptions){
      this.each(function(){
        var $dropDown = $(this);

        $dropDown.empty();
        $dropDown.append("<option value=''>Select " + defaultOption + "...</option>");

        for (var i = 0; i < newOptions.length; i++){
          $dropDown.append("<option value='" + newOptions[i][0] + "'>" + newOptions[i][1] + "</option>");
        }
      });

      return this;
    }

  });

})(jQuery);