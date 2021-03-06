require 'spec_helper'

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples

  subject(:presenter) { described_class.new(content_item, values) }

  let(:government_presenter) { described_class.new(government_finder_content_item) }

  let(:minimal_policy_presenter) { described_class.new(minimal_policy_content_item) }

  let(:national_applicability_presenter) { described_class.new(national_applicability_content_item) }

  let(:national_applicability_with_internal_policies_presenter) { described_class.new(national_applicability_with_internal_policies_content_item) }

  let(:policies_presenter) { described_class.new(policies_finder_content_item) }

  let(:content_item) {
    dummy_http_response = double(
      "net http response",
        code: 200,
        body: govuk_content_schema_example('finder').to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  }

  let(:values) { {} }

  let(:government_finder_content_item) {
    dummy_http_response = double(
      "net http response",
        code: 200,
        body: govuk_content_schema_example('policy_programme', 'policy').to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  }

  let(:minimal_policy_content_item) {
    dummy_http_response = double(
      "net http response",
        code: 200,
        body: govuk_content_schema_example('minimal_policy_area', 'policy').to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  }

  let(:national_applicability_content_item) {
    dummy_http_response = double(
      "net http response",
        code: 200,
        body: govuk_content_schema_example('policy_with_inapplicable_nations', 'policy').to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  }

  let(:policies_finder_content_item) {
    dummy_http_response = double(
      "net http response",
        code: 200,
        body: govuk_content_schema_example('policies_finder', 'finder').to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  }

  let(:internal_policies) {
    {
      'details' => {
        'facets' => [],
        'nation_applicability' => {
          'applies_to' => %w(england northern_ireland),
          'alternative_policies' => [
            {
              'nation' => "scotland",
              'alt_policy_url' => "http://www.gov.uk/scottish-policy-url"
            },
            {
              'nation' => "wales",
              'alt_policy_url' => "http://www.gov.uk/welsh-policy-url"
            }
          ]
        }
      }
    }
  }

  let(:national_applicability_with_internal_policies_content_item) {
    dummy_http_response = double(
      "net http response",
        code: 200,
        body: govuk_content_schema_example('policy_with_inapplicable_nations', 'policy').to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash.merge(internal_policies)
  }

  describe "facets" do
    it "returns the correct facets" do
      expect(subject.facets.count { |f| f.type == "date" }).to eql(1)
      expect(subject.facets.count { |f| f.type == "text" }).to eql(3)
    end

    it "returns the correct filters" do
      expect(subject.filters.length).to eql(2)
    end

    it "returns the correct metadata" do
      expect(subject.metadata.length).to eql(3)
    end

    it "returns correct keys for each facet type" do
      expect(subject.date_metadata_keys).to include("date_of_introduction")
      expect(subject.text_metadata_keys).to include("place_of_origin")
      expect(subject.text_metadata_keys).to include("walk_type")
    end
  end

  describe "#label_for_metadata_key" do
    it "finds the correct key" do
      expect(subject.label_for_metadata_key("date_of_introduction")).to eql("Introduced")
    end
  end

  describe "#atom_url" do
    context "with no values" do
      it "returns the finder URL appended with .atom" do
        expect(presenter.atom_url).to eql("/mosw-reports.atom")
      end
    end

    context "with some values" do
      let(:values) do
        {
          keyword: "legal",
          format: "publication",
          state: "open",
        }
      end

      it "returns the finder URL appended with .atom and query params" do
        expect(presenter.atom_url).to eql("/mosw-reports.atom?format=publication&keyword=legal&state=open")
      end
    end

    context "when the finder is ordered by title" do
      it "atom_url is disabled" do
        expect(policies_presenter.atom_feed_enabled?).to be_falsey
      end
    end
  end

  describe "a government finder" do
    it "sets the government flag" do
      expect(government_presenter.government?).to be_truthy
    end

    it "exposes the government_content_section" do
      expect(government_presenter.government_content_section).to eql("policies")
    end

    it "has metadata" do
      expect(government_presenter.page_metadata.any?).to be_truthy
    end

    it "has people, organisations, and working groups in the from metadata" do
      from = government_presenter.page_metadata[:from].map { |p| p['title'] }
      expect(from).to include("George Dough", "Department for Work and Pensions", "Medical Advisory Group")
    end
  end

  describe "national applicability" do
    it "has applicable nations in the metadata if it is only applicable to some nations" do
      applies_to = national_applicability_presenter.page_metadata[:other]["Applies to"]
      expect(applies_to).to include("England", "Northern Ireland", "Scotland", "Wales")
    end

    it "has no applicable nations in the metadata if it applies to all nations" do
      metadata = government_presenter.page_metadata
      expect(metadata).not_to have_key(:other)
    end

    it "sets rel='external' for an external link" do
      expect(national_applicability_presenter.page_metadata[:other]["Applies to"].include?('rel="external"')).to be_truthy
    end

    it "doesn't set rel='external' for an internal link" do
      expect(national_applicability_with_internal_policies_presenter.page_metadata[:other]["Applies to"].include?('rel="external"')).to be_falsey
    end
  end

  describe "a minimal policy content item" do
    it "doesn't have any page meta data" do
      expect(minimal_policy_presenter.page_metadata.any?).to be_falsey
    end
  end
end
