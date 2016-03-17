require "rails_helper"

describe Admin::UsersController do
  before(:each) do
    @admin = FactoryGirl.create(:admin_user)
    @user = FactoryGirl.create(:user)
    @admin.add_role(:admin)
    sign_in @admin
  end

  xit "changes a users roles" do
    put :change_user_roles, { id: @user.id, roles_names: [:trainer] }
    expect(@user.has_role?(:trainer)).to be(true)
  end
end
