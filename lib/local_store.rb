# frozen_string_literal: true

class LocalStore
  def save(file:, key:, **opts)
    zip_file = opts[:zip_file]
    path = File.join(Rails.root, env_path, key)
    FileUtils.mkdir_p(File.dirname(path))
    zip_file.extract(file, path)
  end

  private

  def env_path
    Rails.configuration.local_lesson_dir
  end
end
