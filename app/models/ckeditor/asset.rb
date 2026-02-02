# frozen_string_literal: true

module Ckeditor
  class Asset < ApplicationRecord
    include Ckeditor::Orm::ActiveRecord::AssetBase

    has_one_attached :data_file
  end
end
