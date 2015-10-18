require "rails_helper"

describe Admin::TopicsController do

  before(:each) do
    @topic1 ||= FactoryGirl.create(:topic, title: "Kale Salad")
    @topic2 ||= FactoryGirl.create(:topic, title: "Cucumber Me up")
    @topic3 ||= FactoryGirl.create(:topic, title: "Sure I like parsley")

    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)
    sign_in @admin
  end

  let(:valid_attributes) do
    { title: "Carrot You Got?" }
  end

  let(:invalid_attributes) do
    { title: "" }
  end

  describe "GET #index" do
    it "assigns all topics as @topics" do
      get :index
      expect(assigns(:topics)).to eq([@topic1, @topic2, @topic3])
    end
  end

  describe "GET #new" do
    it "assigns a new topic as @topic" do
      get :new
      expect(assigns(:topic)).to be_a_new(Topic)
    end
  end

  describe "GET #edit" do
    it "assigns the requested topic as @topic" do
      get :edit, { id: @topic1.to_param }
      expect(assigns(:topic)).to eq(@topic1)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Topic" do
        expect do
          post :create, { topic: valid_attributes }
        end.to change(Topic, :count).by(1)
      end

      it "assigns a newly created topic as @topic" do
        post :create, { topic: valid_attributes }
        expect(assigns(:topic)).to be_a(Topic)
        expect(assigns(:topic)).to be_persisted
      end

      it "redirects to the created topic" do
        post :create, { topic: valid_attributes }
        expect(response).to redirect_to(admin_topics_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved topic as @topic" do
        post :create, { topic: invalid_attributes }
        expect(assigns(:topic)).to be_a_new(Topic)
      end

      it "re-renders the 'new' template" do
        post :create, { topic: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        { title: "You can Beets this!" }
      end

      it "updates the requested topic" do
        put :update, { id: @topic1.to_param, topic: new_attributes }
        @topic1.reload
        expect(@topic1.title).to eq(new_attributes[:title])
      end

      it "assigns the requested topic as @topic" do
        put :update, { id: @topic1.to_param, topic: valid_attributes }
        expect(assigns(:topic)).to eq(@topic1)
      end

      it "redirects to the topic" do
        put :update, { id: @topic1.to_param, topic: valid_attributes }
        expect(response).to redirect_to(admin_topics_path)
      end
    end

    context "with invalid params" do
      it "assigns the topic as @topic" do
        put :update, { id: @topic1.to_param, topic: invalid_attributes }
        expect(assigns(:topic)).to eq(@topic1)
      end

      it "re-renders the 'edit' template" do
        put :update, { id: @topic1.to_param, topic: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  # =>  not yet implemented

  # describe "DELETE #destroy" do
  #   it "destroys the requested topic" do
  #     topic = Topic.create! valid_attributes
  #     expect {
  #       delete :destroy, { id: topic.to_param}
  #     }.to change(Topic, :count).by(-1)
  #   end

  #   it "redirects to the topics list" do
  #     topic = Topic.create! valid_attributes
  #     delete :destroy, { id: topic.to_param}
  #     expect(response).to redirect_to(topics_url)
  #   end
  # end

end
