class LessonStore
  delegate :save, to: :@store

  def initialize
    @store = use_s3? ? S3Store.new : LocalStore.new
  end

  private

  def use_s3?
    Rails.configuration.lesson_store == :s3
  end
end