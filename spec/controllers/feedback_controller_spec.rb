# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe FeedbackController do

  describe "#webconf" do
    let(:current_site) { mock_model(Site) }
    before {
      Site.should_receive(:current).at_least(:once).and_return(current_site)
      current_site.should_receive(:locale)
    }

    context "redirects to the current site's feedback_url if set" do
      before { current_site.should_receive(:feedback_url).and_return("http://test.com/feedback") }
      before(:each) { get :webconf }
      it { should redirect_to("http://test.com/feedback") }
    end

    context "renders :webconf if the current site's feedback_url is empty" do
      before { current_site.should_receive(:feedback_url).and_return("") }
      before(:each) { get :webconf }
      it { should respond_with(:success) }
      it { should render_template(:webconf) }
      it { should render_with_layout("no_sidebar") }
    end

    context "renders :webconf if the current site's feedback_url is nil" do
      before { current_site.should_receive(:feedback_url).and_return(nil) }
      before(:each) { get :webconf }
      it { should respond_with(:success) }
      it { should render_template(:webconf) }
      it { should render_with_layout("no_sidebar") }
    end
  end

end
