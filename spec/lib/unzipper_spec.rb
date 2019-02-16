require "spec_helper"
require "unzipper"
require "rails_helper"

RSpec.describe Unzipper do
  let(:temp_root) { File.join(Rails.root, 'tmp') }
  let(:lesson) { FactoryGirl.create(:lesson) }
  let(:storyline_path) { "public/storylines/#{lesson.story_line.instance.id}" }
  let(:package_file_name) { "#{lesson.story_line.instance.story_line_file_name.chomp('.zip')}" }

  context "initialize" do
    it "without an ASL package" do
      expect { Unzipper.new }.to raise_error(ArgumentError)
    end

    it "with an ASL package" do
      expect(Unzipper.new(lesson.story_line, temp_root)).to be_an_instance_of(Unzipper)
    end
  end

  it "unzips a file" do
    Unzipper.new(lesson.story_line, temp_root).unzip_lesson
    expect(File.join(temp_root, "#{storyline_path}/#{package_file_name}")).to_not be(nil)
  end

  it "overwrites previous contents of destination directory" do
    test_file = File.join(temp_root, "#{storyline_path}/#{package_file_name}/test_file.txt")
    puts test_file
    FileUtils.mkdir_p(File.dirname(test_file))
    File.open(test_file, 'w')
    expect(File.exists?(test_file)).to be_truthy
    Unzipper.new(lesson.story_line, temp_root).unzip_lesson
    expect(File.exists?(test_file)).to be_falsey
  end
end
