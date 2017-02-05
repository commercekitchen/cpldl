require "rails_helper"

describe Admin::CmsPagesController do

  before(:each) do
    @organization = create(:organization)
    request.host = "chipublib.example.com"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @page1   = create(:cms_page, title: "Page1", organization: @organization)
    @page2   = create(:cms_page, title: "Page2", organization: @organization)
    @page3   = create(:cms_page, title: "Page3", organization: @organization)
    @admin = create(:admin_user, organization: @organization)
    @admin.add_role(:admin, @organization)
    sign_in @admin
  end

  describe "GET #new" do
    it "assigns a new page as @page" do
      get :new
      expect(assigns(:cms_page)).to be_a_new(CmsPage)
    end
  end

  describe "GET #edit" do
    it "assigns the requested page as @page" do
      get :edit, { id: @page1.to_param }
      expect(assigns(:cms_page)).to eq(@page1)
    end
  end

  describe "PATCH #update_pub_status" do
    it "updates the status" do
      patch :update_pub_status, { cms_page_id: @page1.id.to_param, value: "P" }
      @page1.reload
      expect(@page1.pub_status).to eq("P")
    end

    it "updates the pub_date if status is published" do
      Timecop.freeze do
        patch :update_pub_status, { cms_page_id: @page1.id.to_param, value: "A" }
        @page1.reload
        expect(@page1.pub_date).to be(nil)

        patch :update_pub_status, { cms_page_id: @page1.id.to_param, value: "P" }
        @page1.reload
        expect(@page1.pub_date.to_i).to eq(Time.zone.now.to_i)
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      { title: "This old page",
        body: "Would you hold it against me?",
        language_id: 1,
        author: "Bob Snob",
        audience: "Auth",
        pub_status: "D",
        pub_date: nil,
        seo_page_title: "A New Page",
        meta_desc: "Meta This and That"
      }
    end

    let(:invalid_attributes) do
      { title: "",
        author: "",
        audience: "",
        pub_status: "",
        seo_page_title: "",
        meta_desc: "Meta This and That"
      }
    end

    context "with valid params" do
      it "creates a new page" do
        expect do
          post :create, { cms_page: valid_attributes, commit: "Save Page" }
        end.to change(CmsPage, :count).by(1)
      end

      it "assigns a newly created page as @page" do
        post :create, { cms_page: valid_attributes, commit: "Save Page" }
        expect(assigns(:cms_page)).to be_a(CmsPage)
        expect(assigns(:cms_page)).to be_persisted
      end

      it "redirects to the admin edit view of the page" do
        post :create, { cms_page: valid_attributes, commit: "Save Page" }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_admin_cms_page_path(CmsPage.find_by_title(valid_attributes[:title])))
      end

      it "renders a preview of page" do
        post :create, { cms_page: valid_attributes, commit: "Preview Page" }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end

      it "sets the pub_date if page is saved as (P)ublished" do
        valid_attributes[:pub_status] = "P"
        Timecop.freeze do
          post :create, { cms_page: valid_attributes, commit: "Save Page" }
          page = CmsPage.find_by_title(valid_attributes[:title])
          expect(page.pub_date.to_i).to eq(Time.zone.now.to_i)
        end
      end
    end

    context "with invalid params" do
      it "does not create a page with invalid attributes" do
        expect do
          post :create, { cms_page: invalid_attributes, commit: "Save Page" }
        end.to change(CmsPage, :count).by(0)
      end

      it "re-renders the 'new' template" do
        post :create, { cms_page: invalid_attributes, commit: "Save Page" }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "POST #update" do
    context "with valid params" do
      it "updates an existing page" do
        patch :update, { id: @page1.to_param, cms_page: @page1.attributes, commit: "Save Page" }
        expect(response).to redirect_to(edit_admin_cms_page_path(@page1))
      end

      it "updates pub_date if pub_status changes" do
        patch :update, id: @page1.to_param, cms_page: { pub_status: "P" }, commit: "Save Page"
        @page1.reload
        expect(@page1.pub_date.to_i).to eq(Time.zone.now.to_i)

        patch :update, id: @page1.to_param, cms_page: { pub_status: "D" }, commit: "Save Page"
        @page1.reload
        expect(@page1.pub_date).to eq(nil)
      end

      it "renders a preview of page" do
        patch :update, { id: @page1.to_param, cms_page: @page1.attributes, commit: "Preview Page" }
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end

      it "re-renders edit if update fails" do
        patch :update, id: @page1.to_param, cms_page: { title: nil }, commit: "Save Page"
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    context "success" do
      it "deletes a page" do
        expect { delete :destroy, id: @page1.to_param }.to change(CmsPage, :count).by(-1)
      end
    end
  end
end
