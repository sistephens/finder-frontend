require "spec_helper"

describe DateFacet do
  let(:facet_struct) {
    OpenStruct.new(
      type: "date",
      name: "Occurred",
      key: "date_of_occurrence",
      preposition: "occurred",
    )
  }

  subject { DateFacet.new(facet_struct) }

  before do
    subject.value = value
  end

  describe "#sentence_fragment" do
    let(:value) { nil }

    context "single date value" do
      let(:value) { { from: "22/09/1988" } }
      specify {
        subject.sentence_fragment.preposition.should eql("occurred after")
        subject.sentence_fragment.values.first.label.should eql("22 September 1988")
        subject.sentence_fragment.values.first.parameter_key.should eql("date_of_occurrence")
      }
    end

    context "6 digit date value" do
      let(:value) { { to: "22/09/14" } }
      specify {
        subject.sentence_fragment.preposition.should eql("occurred before")
        subject.sentence_fragment.values.first.label.should eql("22 September 2014")
        subject.sentence_fragment.values.first.parameter_key.should eql("date_of_occurrence")
      }
    end

    context "multiple date values" do
      let(:value) {
        {
          "from" => "22/09/1988",
          "to" => "22/09/2014",
        }
      }
      specify {
        subject.sentence_fragment.preposition.should eql("occurred between")

        subject.sentence_fragment.values.first.label.should eql("22 September 1988")
        subject.sentence_fragment.values.first.parameter_key.should eql("date_of_occurrence")

        subject.sentence_fragment.values.last.label.should eql("22 September 2014")
        subject.sentence_fragment.values.last.parameter_key.should eql("date_of_occurrence")
      }
    end
  end
end
