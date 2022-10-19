class PreferenceSetsController < ApplicationController
  # POST /preference_sets
  def create
    # find or create preference_set
    # if the preference_set exists, we need to add the new preference to the hash
    # located on case_volunteer_columns
    # [2] pry(#<PreferenceSetsController>)> PreferenceSet.new
    # => #<PreferenceSet:0x00007fe7c9dba700
    # id: nil,
    # user_id: nil,
    # case_volunteer_columns: "{}",
    # created_at: nil,
    # updated_at: nil>
  end

  private

  def preference_set_params
    params.require(:preference_set)
      .permit(:name)
  end
end
