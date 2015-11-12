module Admin
  class ContentsController < BaseController
    def new
      @content = Content.new
    end

    def create
      Content.create(content_params)
      # @content.save
    end

    private

    def content_params
      params.require(:content).permit(:body,
                                      :language_id,
                                      :cms_page_id)
    end
  end
end