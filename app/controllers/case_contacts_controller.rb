# CaseContactsController with default actions
class CaseContactsController < ApplicationController
  before_action :set_case_contact, only: %i[show edit update destroy]

  # GET /case_contacts
  # GET /case_contacts.json
  def index
    @case_contacts = CaseContact.all.decorate
  end

  # GET /case_contacts/1
  # GET /case_contacts/1.json
  def show
    @case_contact_number = CasaCase.find(@case_contact.casa_case_id).case_number
  end

  # GET /case_contacts/new
  def new
    @case_contact = CaseContact.new
    @casa_cases = current_user.casa_cases
  end

  # GET /case_contacts/1/edit
  def edit
    @casa_cases = current_user.casa_cases
  end

  def create
    @case_contact = CaseContact.new(create_case_contact_params)

    respond_to do |format|
      if @case_contact.save
        format.html { redirect_to @case_contact.decorate, notice: 'Case contact was successfully created.' }
        format.json { render :show, status: :created, location: @case_contact }
      else
        format.html { render :new }
        format.json { render json: @case_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /case_contacts/1
  # PATCH/PUT /case_contacts/1.json
  def update
    respond_to do |format|
      if @case_contact.update(case_contact_params)
        format.html { redirect_to @case_contact.decorate, notice: 'Case contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @case_contact }
      else
        format.html { render :edit }
        format.json { render json: @case_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /case_contacts/1
  # DELETE /case_contacts/1.json
  def destroy
    @case_contact.destroy
    respond_to do |format|
      format.html { redirect_to case_contacts_url, notice: 'Case contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_case_contact
    @case_contact = CaseContact.find(params[:id])
  end

  # This can probably be combined with case_contact_params below, but was unsure about
  # this line `.with_casa_case(current_user.casa_cases.first)`
  def create_case_contact_params
    CaseContactParameters
      .new(params)
      .with_creator(current_user)
      .with_casa_case(CasaCase.find(params[:case_contact][:casa_case_id]))
      .with_converted_duration_minutes(params[:case_contact][:duration_hours].to_i)
  end

  def case_contact_params
    CaseContactParameters
      .new(params)
      .with_creator(current_user)
      .with_casa_case(current_user.casa_cases.first)
      .with_converted_duration_minutes(params[:case_contact][:duration_hours].to_i)
  end
end
