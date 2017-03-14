require "rails_helper"

describe Category do

  context "validations" do
    before(:each) do
      @organization = FactoryGirl.create(:organization)
      @category1 = FactoryGirl.create(:category, category_order: 1)
      @category1.organization.reload
      @new_category = Category.new
    end

    it "fail initially" do
      expect(@new_category).not_to be_valid
    end

    it "requires category name" do
      @new_category.valid?
      expect(@new_category.errors.full_messages).to include("Category Name can't be blank")
    end

    it "fail with repeated name for same org" do
      @new_category.update(name: @category1.name, organization: @category1.organization)
      expect(@new_category).not_to be_valid
    end

    it "pass with unique name for same org" do
      @new_category.update(name: "#{@category1.name}_new", organization: @category1.organization)
      expect(@new_category).to be_valid
    end

    it "pass with repeated name for different org" do
      @new_category.update(name: @category1.name, organization: @organization)
      expect(@new_category).to be_valid
    end

    it "fail if category order is repeated within org" do
      @new_category.update(name: "#{@category1.name}_new", organization: @category1.organization, category_order: 1)
      expect(@new_category).not_to be_valid
    end

    it "pass if category order is not repeated within org" do
      @new_category.update(name: "#{@category1.name}_new", organization: @category1.organization, category_order: 2)
      expect(@new_category).to be_valid
    end

    it "pass if category order is repeated in a different org" do
      @new_category.update(name: "#{@category1.name}_new", organization: @organization, category_order: 1)
      expect(@new_category).to be_valid
    end
  end
end