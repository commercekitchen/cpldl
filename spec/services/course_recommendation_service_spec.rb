require "rails_helper"

describe CourseRecommendationService do

  let(:topics) {
    {
      1 => "Job Search",
      2 => "Education: Child",
      3 => "Government",
      4 => "Education: Adult",
      5 => "Communication Social Media",
      6 => "Security",
      7 => "Software Apps",
      8 => "Information Searching"
    }
  }

  before(:each) do
    @spanish = create(:spanish_lang)
    @english = create(:language)
    @organization = create(:organization)
    @other_organization = create(:organization)
    @user = create(:user, organization: @organization)

    @core_topic = create(:topic, title: "Core")
    @other_topic = create(:topic)

    # Create applicable courses
    ["M", "D"].each do |format|
      ["Beginner", "Intermediate"].each do |level|
        en_course = create(:course, language: @english, format: format, level: level, topics: [@core_topic], organization: @organization)
        es_course = create(:course, language: @spanish, format: format, level: level, topics: [@core_topic], organization: @organization)
      end
    end

    topics.each do |k, v|
      topic = create(:topic, title: v)
      en_course = create(:course, language: @english, topics: [topic], organization: @organization)
      es_course = create(:course, language: @spanish, topics: [topic], organization: @organization)
    end

    # Create non-applicable course
    create(:course, language: @english, topics: [@other_topic])
    @draft_desktop_course = create(:course, language: @english, format: "D", pub_status: "D", organization: @organization)
    @draft_mobile_course = create(:course, language: @english, format: "M", pub_status: "D", organization: @organization)
  end

  describe "new service instance" do
    before(:each) do
      @responses = {
        "set_one" => "1",
        "set_two" => "2",
        "set_three" => "3"
      }

      @service = CourseRecommendationService.new(@organization.id, @responses)
    end

    it "assigns org" do
      expect(@service.instance_variable_get(:@org)).to eq(@organization)
    end

    it "assigns responses" do
      expect(@service.instance_variable_get(:@responses)).to eq(@responses)
    end
  end

  describe "add recommended courses" do
    it "should create a course progress for each desktop level" do
      expect do
        ["1", "2"].each do |d_level|
          responses = {
            "set_two" => d_level
          }

          @service = CourseRecommendationService.new(@organization.id, responses)
          @service.add_recommended_courses(@user.id)
        end
      end.to change(CourseProgress, :count).by(2)
    end

    it "should create a course progress for each mobile level" do
      expect do
        ["1", "2"].each do |m_level|
          responses = {
            "set_one" => m_level
          }

          @service = CourseRecommendationService.new(@organization.id, responses)
          @service.add_recommended_courses(@user.id)
        end
      end.to change(CourseProgress, :count).by(2)
    end

    it "should create a course progress for each topic" do
      expect do
        topics.each do |topic_int, topic_string|
          responses = {
            "set_three" => topic_int
          }

          @service = CourseRecommendationService.new(@organization.id, responses)
          @service.add_recommended_courses(@user.id)
        end
      end.to change(CourseProgress, :count).by(8)
    end
  end

  describe "spanish language course" do
    before(:each) do
      responses = {
        "set_one" => "1",
        "set_two" => "2",
        "set_three" => "3"
      }

      I18n.locale = :es
      @service = CourseRecommendationService.new(@organization.id, responses)
    end

    it "should create a course progress" do
      expect do
        @service.add_recommended_courses(@user.id)
      end.to change(CourseProgress, :count).by(3)
    end

    it "should create a course progress for a spanish course" do
      @service.add_recommended_courses(@user.id)
      expect(CourseProgress.last.course.language_id).to eq(@spanish.id)
    end
  end
end
