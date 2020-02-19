# frozen_string_literal: true

module Admin
  module CoursesHelper
    def link_to_add_fields(name, form, association, attachment_type)

      new_object = form.object.class.reflect_on_association(association).klass.new

      fields = form.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
        render('admin/courses/forms/attachment_upload', attachment_form: builder, attachment_type: attachment_type, removable: true)
      end

      link_to(name, "javascript:add_fields('#{association}',
                                           '#{escape_javascript(fields)}',
                                           '#{attachment_type}')", id: "add-attachment-#{attachment_type}")
    end

    def link_to_remove_child(name)
      link_to(name, 'javascript:remove_child', class: 'remove_child')
    end
  end
end
