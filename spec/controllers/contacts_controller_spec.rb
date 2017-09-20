require "rails_helper"

describe ContactController do

  before(:each) do
    @www = create(:organization, subdomain: "www")
    @request.host = "www.digitallearn.org"
  end

  describe "GET #new" do

    it "assigns a new instance of a contact" do
      @contact = FactoryGirl.create(:contact)
      get :new
      expect(assigns(:contact)).to be_an_instance_of(Contact)
    end

    it "redirects to the www subdomain if a non-www version is requested" do
      @request.host = "npl.digitallearn.org"
      get :new
      expect(response).to redirect_to new_contact_url(subdomain: "www")
    end

  end

  describe "POST #create" do

    before :each do
      @contact = FactoryGirl.create(:contact)
    end

    let(:valid_attributes) do
      {
        first_name: "Alan",
        last_name: "Turing",
        organization: "New York Public Library",
        city: "New York",
        state: "NY",
        email: "ny@example.com",
        phone: "5551231234",
        comments: "We'd like one too!"
      }
    end

    let(:invalid_attributes) do
      {
        first_name: "",
        last_name: "",
        organization: "",
        city: "",
        state: "",
        email: "",
        comments: ""
      }
    end

    it "correctly assigns the passed in info" do
      post :create, contact: valid_attributes
      contact = Contact.last
      expect(contact.first_name).to eq "Alan"
      expect(contact.last_name).to eq "Turing"
      expect(contact.organization).to eq "New York Public Library"
      expect(contact.city).to eq "New York"
      expect(contact.state).to eq "NY"
      expect(contact.email).to eq "ny@example.com"
      expect(contact.phone).to eq "5551231234"
      expect(contact.comments).to eq "We'd like one too!"
    end

    xit "sends the contact email on successful submission" do
      # TODO: I don't know how to do this with rspec mocks, here's how to do it in Mocha.
      # I'd like to switch this project over to mocha for consistency, but other tests would need
      # fixed too.
      success_object = stub(deliver_later: true)
      ContactMailer.expects(:email).once.returns(success_object)
      post :create, contact: valid_attributes
    end

    it "renders the new view if there is missing information" do
      @contact = FactoryGirl.create(:contact)
      post :create, contact: invalid_attributes
      expect(response).to render_template :new
    end

  end

end
