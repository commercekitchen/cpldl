# frozen_string_literal: true

module Admin
  module CoursesHelper
    def link_to_add_fields(name, form, association, prefix)

      new_object = form.object.class.reflect_on_association(association).klass.new

      fields = form.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
        render('admin/courses/forms/' + prefix + '_' + association.to_s.singularize + '_fields', f: builder)
      end

      link_to(name, "javascript:add_fields('#{association}',
                                           '#{escape_javascript(fields)}',
                                           '#{prefix}')", id: "add-attachment-#{prefix}")
    end

    def link_to_remove_child(name)
      link_to(name, 'javascript:remove_child', class: 'remove_child')
    end
  end
end
