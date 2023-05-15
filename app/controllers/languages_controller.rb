class LanguagesController < ApplicationController
  before_action :set_language, only: %i[edit update]

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

  private

  def set_language
    @language = Language.find(params[:id] || params[:language_id])
  end

  def language_params
    params.require(:language).permit(:name)
  end
end
