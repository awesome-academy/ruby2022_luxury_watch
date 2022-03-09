require "rails_helper"

RSpec.describe DiscountsController, type: :controller do
  describe "GET #show" do
    let!(:discount){FactoryBot.create :discount,
                                      start: Time.zone.now,
                                      end: Time.now + 10.days}

    context "when check code success" do
      setup do
        @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
      end
      it "should check code success" do
        get :show, params: {code: "aaaaa", total: 100000}
      end
    end

    context "when check code not found" do
      before do
        get :show, params: {code: "ccc", total: 100000}
      end
      it "should show flash error" do
        expect(flash[:warning]).to eq I18n.t("not_found_discount")
      end

      it "should redirect to root path" do
        expect(response).to redirect_to root_path
      end
    end

    context "when check code not found xhr true" do
      it "should redirect when xhr true" do
        get :show, xhr: true, params: {code: "ccc", total: 100000}
      end
    end
  end
end
