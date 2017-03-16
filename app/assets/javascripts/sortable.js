$(document).ready(function(){
  sortableTable.set_positions();
  sortableTable.init_sortables();
});

var sortableTable =  (function(){
  return {
    set_positions: function(){
      // loop through and give each task a data-pos
      // attribute that holds its position in the DOM
      $(".panel.panel-default").each(function(i){
          $(this).attr("data-pos",i+1);
      });
    },

    init_sortables: function(){
      $(".sortable").sortable({handle: ":not(a)"});

      // after the order changes
      $(".sortable").sortable({handle: ":not(a)"}).bind("sortupdate", function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        sortableTable.set_positions();

        // populate the updated_order array with the new task positions
        $(".sortable-item").each(function(i){
            updated_order.push({ id: $(this).data("id"), position: i+1 });
        });

        // send the updated order via ajax
        $.ajax({
            type: "PUT",
            url: "/admin/" + $(".sortable-list").data("page") + "/sort",
            // url: '/admin/courses/sort',
            data: { order: updated_order }
        });
      });
    }
  }
})();
