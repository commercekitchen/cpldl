class LessonStore
  delegate :save, to: :@store

  def initialize
    @store = local? ? LocalStore.new : S3Store.new
  end

  private

  def local?
    Rails.env.development? || Rails.env.test?
  end
end