# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachmentPolicy, type: :policy do
  it_behaves_like "AdminOnly Policy" do
    let(:organization) { FactoryBot.create(:organization) }

    let(:course) { FactoryBot.create(:course, organization: organization) }

    let!(:subsite_record) { FactoryBot.create(:attachment, course: course) }
    let!(:other_subsite_record) { FactoryBot.create(:attachment) }
  end
end
