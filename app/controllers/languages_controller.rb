class LanguagesController < ApplicationController
  before_action :set_language, only: %i[edit update add_to_volunteer remove_from_volunteer]

  def new
    authorize Language
    @language = Language.new
  end

  def edit
    authorize @language
  end

  def create
    authorize Language
    @language = Language.new(language_params)
    @language.casa_org = current_organization
    respond_to do |format|
      if @language.save
        format.html { redirect_to edit_casa_org_path(current_organization.id), notice: "Language was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @language
    respond_to do |format|
      if @language.update(language_params)
        format.html { redirect_to edit_casa_org_path(current_organization.id), notice: "Language was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def add_to_volunteer
    authorize @language
    begin
      current_user.languages << @language
      redirect_to edit_users_path, notice: "#{@language.name} was added to your languages list."
    rescue ActiveRecord::RecordInvalid
      redirect_to edit_users_path, notice: "Error unable to add #{@language.name} to your languages list!"
    end
  end

  def remove_from_volunteer
    authorize @language
    current_user.languages.delete @language
    if current_user.save
      redirect_to edit_users_path, notice: "#{@language.name} was removed from your languages list."
    else
      redirect_to edit_users_path, notice: "Error unable to remove #{@language.name} from your languages list!"
    end
  end

  private

  def set_language
    @language = Language.find(params[:id] || params[:language_id])
  end

  def language_params
    params.require(:language).permit(:name)
  end
end
