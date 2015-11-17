module Admin
  module CmsPageHelper
    def page_contents_for_language
      @cms_page.contents.select { |l| l.language_id == @language }.pop
    end
  end
end
