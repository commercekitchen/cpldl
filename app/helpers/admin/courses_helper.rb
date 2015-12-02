module Admin
  module CoursesHelper
    def link_to_add_fields(name, f, association, prefix)

      new_object = f.object.class.reflect_on_association(association).klass.new

      fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render("admin/courses/forms/" + prefix + association.to_s.singularize + "_fields", :f => builder)
      end

      link_to(name, "javascript:add_fields('#{association}', '#{escape_javascript(fields)}')", id:"add-attachment")
    end

    # def link_to_add_fields_right(name, f, association, prefix)
    #   new_object = f.object.class.reflect_on_association(association).klass.new

    #   fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
    #     render("admin/courses/forms/push")
    #     render("admin/courses/forms/" + prefix + association.to_s.singularize + "_fields", :f => builder)
    #   end

    #   link_to(name, "javascript:add_fields('#{association}', '#{escape_javascript(fields)}')", id:"add-attachment")
    # end

    def link_to_remove_child(name)
      link_to(name, "javascript:remove_child", class:"remove_child")
    end
  end
end
