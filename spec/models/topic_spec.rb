require 'rails_helper'

RSpec.describe Topic, type: :model do
  context 'scopes' do
    describe '#for_organization' do
      let(:org) { create(:organization) }
      let(:other_org) { create(:organization, subdomain: 'other') }

      it 'includes all default and org-specific topics' do
        default_topic = create(:topic, title: 'Default Topic')
        org_topic = create(:topic, organization: org, title: 'Org Topic')
        other_org_topic = create(:topic, organization: other_org, title: 'Other Org Topic')

        expect(Topic.for_organization(org)).to contain_exactly(default_topic, org_topic)
      end
    end
  end
end