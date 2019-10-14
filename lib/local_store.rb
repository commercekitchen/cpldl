class LocalStore
  def save(file:, key:, acl:, zip_file:)
    path = File.join(Rails.root, env_path, key)
    FileUtils.mkdir_p(File.dirname(path))
    zip_file.extract(file, path)
  end

  private

  def env_path
    return 'tmp' if Rails.env.test?
    return 'public' if Rails.env.development?
  end
end