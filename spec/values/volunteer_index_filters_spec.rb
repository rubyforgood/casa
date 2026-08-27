require "rails_helper"

RSpec.describe VolunteerIndexFilters do
  # supervisor_ids is the value object's own argument; everything else is a GET filter param.
  def filters(supervisor_ids: [], **params)
    described_class.new(ActionController::Parameters.new(params), supervisor_ids: supervisor_ids)
  end

  describe "normalizing the GET filters" do
    it "defaults everything when no params are given" do
      subject = filters

      expect(subject.search).to eq ""
      expect(subject.status).to eq "active"
      expect(subject.supervisor).to eq ""
      expect(subject.transition).to eq ""
      expect(subject.extra_languages).to eq ""
      expect(subject.sort).to eq "display_name"
      expect(subject.direction).to eq "asc"
    end

    it "keeps values that are in the allowed set" do
      subject = filters(
        search: "ali", status: "all", supervisor: "unassigned", transition: "yes",
        languages: "no", sort: "email", direction: "desc"
      )

      expect(subject.search).to eq "ali"
      expect(subject.status).to eq "all"
      expect(subject.supervisor).to eq "unassigned"
      expect(subject.transition).to eq "yes"
      expect(subject.extra_languages).to eq "no"
      expect(subject.sort).to eq "email"
      expect(subject.direction).to eq "desc"
    end

    it "falls back to the defaults for values outside the allowed set" do
      subject = filters(status: "pending", transition: "maybe", languages: "maybe", sort: "'; drop table --", direction: "sideways")

      expect(subject.status).to eq "active"
      expect(subject.transition).to eq ""
      expect(subject.extra_languages).to eq ""
      expect(subject.sort).to eq "display_name"
      expect(subject.direction).to eq "asc"
    end

    it "coerces a non-string search to a string" do
      expect(filters(search: 42).search).to eq "42"
      expect(filters(supervisor: 7).supervisor).to eq "7"
    end
  end

  describe "#to_datatable_params" do
    it "maps the defaults onto the datatable's param shape" do
      expect(filters.to_datatable_params).to eq(
        {
          search: {value: ""},
          additional_filters: {
            active: %w[true],
            supervisor: [""],
            transition_aged_youth: %w[true false],
            extra_languages: nil
          },
          columns: {"0" => {name: "display_name"}},
          order: {"0" => {column: "0", dir: "asc"}}
        }.with_indifferent_access
      )
    end

    it "is indifferent about string and symbol keys" do
      params = filters.to_datatable_params

      expect(params["search"]["value"]).to eq params[:search][:value]
    end

    describe "the active filter" do
      it "asks for active volunteers by default" do
        expect(filters.to_datatable_params[:additional_filters][:active]).to eq %w[true]
      end

      it "asks for inactive volunteers when the status is inactive" do
        expect(filters(status: "inactive").to_datatable_params[:additional_filters][:active]).to eq %w[false]
      end

      it "asks for both when the status is all" do
        expect(filters(status: "all").to_datatable_params[:additional_filters][:active]).to eq %w[true false]
      end
    end

    describe "the supervisor filter" do
      let(:supervisor_ids) { %w[3 5] }

      it "includes the unassigned marker plus every active supervisor id when unfiltered" do
        expect(filters(supervisor_ids: supervisor_ids).to_datatable_params[:additional_filters][:supervisor]).to eq ["", "3", "5"]
      end

      it "includes the unassigned marker plus every active supervisor id for 'all'" do
        subject = filters(supervisor: "all", supervisor_ids: supervisor_ids)

        expect(subject.to_datatable_params[:additional_filters][:supervisor]).to eq ["", "3", "5"]
      end

      it "asks for only volunteers with no supervisor when unassigned" do
        subject = filters(supervisor: "unassigned", supervisor_ids: supervisor_ids)

        expect(subject.to_datatable_params[:additional_filters][:supervisor]).to eq [""]
      end

      it "asks for the one supervisor when given an id" do
        subject = filters(supervisor: "5", supervisor_ids: supervisor_ids)

        expect(subject.to_datatable_params[:additional_filters][:supervisor]).to eq ["5"]
      end
    end

    describe "the yes/no filters" do
      it "translates yes and no into the datatable's boolean strings" do
        yes = filters(transition: "yes", languages: "yes").to_datatable_params[:additional_filters]
        no = filters(transition: "no", languages: "no").to_datatable_params[:additional_filters]

        expect(yes[:transition_aged_youth]).to eq %w[true]
        expect(yes[:extra_languages]).to eq %w[true]
        expect(no[:transition_aged_youth]).to eq %w[false]
        expect(no[:extra_languages]).to eq %w[false]
      end

      it "asks for both transition values but omits the language filter entirely when unset" do
        additional_filters = filters.to_datatable_params[:additional_filters]

        expect(additional_filters[:transition_aged_youth]).to eq %w[true false]
        expect(additional_filters[:extra_languages]).to be_nil
      end
    end
  end
end
