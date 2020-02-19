# frozen_string_literal: true

require 'rails_helper'

describe ContactsController do

  before(:each) do
    @www = create(:default_organization)
    @request.host = 'www.digitallearn.org'
  end

  describe 'GET #new' do

    it 'assigns a new instance of a contact' do
      @contact = FactoryBot.create(:contact)
      get :new
      expect(assigns(:contact)).to be_an_instance_of(Contact)
    end

    it 'redirects to the www subdomain if a non-www version is requested' do
      @request.host = 'npl.digitallearn.org'
      get :new
      expect(response).to redirect_to new_contact_url(subdomain: 'www')
    end

  end

  describe 'POST #create' do

    before :each do
      @contact = FactoryBot.create(:contact)
    end

    let(:valid_attributes) do
      {
        first_name: 'Alan',
        last_name: 'Turing',
        organization: 'New York Public Library',
        city: 'New York',
        state: 'NY',
        email: 'ny@example.com',
        phone: '5551231234',
        comments: "We'd like one too!"
      }
    end

    let(:invalid_attributes) do
      {
        first_name: '',
        last_name: '',
        organization: '',
        city: '',
        state: '',
        email: '',
        comments: ''
      }
    end

    it 'correctly assigns the passed in info' do
      post :create, params: { contact: valid_attributes }
      contact = Contact.last
      expect(contact.first_name).to eq 'Alan'
      expect(contact.last_name).to eq 'Turing'
      expect(contact.organization).to eq 'New York Public Library'
      expect(contact.city).to eq 'New York'
      expect(contact.state).to eq 'NY'
      expect(contact.email).to eq 'ny@example.com'
      expect(contact.phone).to eq '5551231234'
      expect(contact.comments).to eq "We'd like one too!"
    end

    it 'sends the contact email on successful submission' do
      expect do
        post :create, params: { contact: valid_attributes }
      end.to have_enqueued_job.on_queue('mailers')
    end

    it 'renders the new view if there is missing information' do
      @contact = FactoryBot.create(:contact)
      post :create, params: { contact: invalid_attributes }
      expect(response).to render_template :new
    end

    it 'handles long emails gracefulle' do
      long_email = "tom+long_email_address@ckdtech.co"
      post :create, params: { contact: valid_attributes.merge(email: long_email) }
      expect(response).to render_template :new
    end

  end

end
