require "spec_helper"
require "unzipper"
require "rails_helper"

RSpec.describe Unzipper do
  before(:each) do
    @lesson = FactoryGirl.create(:lesson)
  end

  context "initialize" do
    it "without an ASL package" do
      expect { Unzipper.new }.to raise_error(ArgumentError)
    end

    it "with an ASL package" do
      expect(Unzipper.new(@lesson.story_line)).to be_an_instance_of(Unzipper)
    end
  end

  it "unzips a file" do
    Unzipper.new(@lesson.story_line)
    expect(File.join(Rails.root, "public/storylines/#{@lesson.story_line
                                                             .instance.id}/#{@lesson.story_line
                                                                                    .instance.story_line_file_name
                                                                                    .chomp('.zip')}")).to_not be(nil)
  end
end
