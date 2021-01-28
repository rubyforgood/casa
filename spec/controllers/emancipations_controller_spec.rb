require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do

  it"raises add_category error message" do  #when "add_category"
    test_case_category = CasaCaseCasaCase.new
    test_case_category.add_emancipation_category(params[:1])
    test_case_category.add_emancipation_category(params[:2])
    test_case_category.add_emancipation_category(params[:3])
    expect{ test_case_category.add_emancipation_category(params[:4]) }.to raise("Param check_item_action did not contain a supported action")
  end

  it"raises add_option error message" do
    test_case_category = CasaCaseCasaCase.new
    test_case_category.add_emancipation_option(params[:1])
    test_case_category.add_emancipation_option(params[:2])
    test_case_category.add_emancipation_option(params[:3])
    expect{ test_case_category.add_emancipation_option(params[:4]) }.to raise("Param check_item_action did not contain a supported action")
  end

  it"raises delete_category error message" do
  end

  it"raises delete_option error message" do
  end

  it"raises set_option error message" do
  end
end

# rescue ActiveRecord::RecordNotFound
#   render json: {error: "Could not find option from id given by param check_item_id"}
# rescue ActiveRecord::RecordNotUnique
#   render json: {error: "Option already added to case"}
# rescue => error
#   render json: {error: error.message}
