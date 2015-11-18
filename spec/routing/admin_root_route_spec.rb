require "rails_helper"

describe "/admin should be a valid route" do

  it "routes /admin to /admin/dashboard" do
    expect(get: "/admin").to route_to(controller: "admin/dashboard", action: "index")
  end
end
