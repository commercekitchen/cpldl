module Admin
  module SchoolsHelper
    def school_type_options
      School.school_types.keys.map { |type| [type.titleize, type] }
    end
  end
end