require "rails_helper"

describe Admin::LanguagesController do
  before(:each) do
    @language1 = FactoryGirl.create(:language, name: "German")
    @language2 = FactoryGirl.create(:language, name: "Swedish")
    @language3 = FactoryGirl.create(:language, name: "Korean")

    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)
    sign_in @admin
  end

  let(:valid_attributes) do
    { name: "Kingon" }
  end

  let(:invalid_attributes) do
    { name: "" }
  end

  describe "GET #index" do
    it "assigns all languages as @languages" do
      get :index
      expect(assigns(:languages)).to eq([@language1, @language2, @language3])
    end
  end

  describe "GET #new" do
    it "assigns a new language as @language" do
      get :new
      expect(assigns(:language)).to be_a_new(Language)
    end
  end

  describe "GET #edit" do
    it "assigns the requested language as @language" do
      get :edit, id: @language1.to_param
      expect(assigns(:language)).to eq(@language1)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Language" do
        expect do
          post :create, { language: valid_attributes }
        end.to change(Language, :count).by(1)
      end

      it "assigns a newly created language as @language" do
        post :create, { language: valid_attributes }
        expect(assigns(:language)).to be_a(Language)
        expect(assigns(:language)).to be_persisted
      end

      it "redirects to language index" do
        post :create, { language: valid_attributes }
        expect(response).to redirect_to(admin_languages_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved language as @language" do
        post :create, { language: invalid_attributes }
        expect(assigns(:language)).to be_a_new(Language)
      end

      it "re-renders the 'new' template" do
        post :create, { language: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        { name: "Goober" }
      end

      it "updates the requested language" do
        put :update, { id: @language1.to_param, language: new_attributes }
        @language1.reload
        expect(@language1.name).to eq(new_attributes[:name])
      end

      it "assigns the requested language as @language" do
        put :update, { id: @language1.to_param, language: valid_attributes }
        expect(assigns(:language)).to eq(@language1)
      end

      it "redirects to the language index" do
        put :update, { id: @language1.to_param, language: valid_attributes }
        expect(response).to redirect_to(admin_languages_path)
      end
    end

    context "with invalid params" do
      it "assigns the language as @language" do
        put :update, { id: @language1.to_param, language: invalid_attributes }
        expect(assigns(:language)).to eq(@language1)
      end

      it "re-renders the 'edit' template" do
        put :update, { id: @language1.to_param, language: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  # => not sure if we will allow delete yet

  # describe "DELETE #destroy" do
  #   it "destroys the requested language" do
  #     language = Language.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => language.to_param}, valid_session
  #     }.to change(Language, :count).by(-1)
  #   end

  #   it "redirects to the languages list" do
  #     language = Language.create! valid_attributes
  #     delete :destroy, {:id => language.to_param}, valid_session
  #     expect(response).to redirect_to(languages_url)
  #   end
  # end
end
