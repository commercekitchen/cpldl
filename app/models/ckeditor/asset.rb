# class Ckeditor::Asset < ActiveRecord::Base
#   include Ckeditor::Orm::ActiveRecord::AssetBase
#   include Ckeditor::Backend::Paperclip
# end

module Ckeditor
  class Asset < ActiveRecord::Base
    include Ckeditor::Orm::ActiveRecord::AssetBase
    include Ckeditor::Backend::Paperclip
  end
end