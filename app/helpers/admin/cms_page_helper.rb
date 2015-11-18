module Admin
  module CmsPageHelper
    def page_contents_for_language
      @cms_page.contents.select { |l| l.language == @language }.pop
    end
  end
end
