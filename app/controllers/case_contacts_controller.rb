class CaseContactsController < ApplicationController
  before_action :set_case_contact, only: [:show, :edit, :update, :destroy]

  # GET /case_contacts
  # GET /case_contacts.json
  def index
    @case_contacts = CaseContact.all
  end

  # GET /case_contacts/1
  # GET /case_contacts/1.json
  def show
  end

  # GET /case_contacts/new
  def new
    @case_contact = CaseContact.new
  end

  # GET /case_contacts/1/edit
  def edit
  end

  def create
    @case_contact = CaseContact.new(case_contact_params)

    respond_to do |format|
      if @case_contact.save
        format.html { redirect_to @case_contact, notice: 'Case contact was successfully created.' }
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
        format.html { redirect_to @case_contact, notice: 'Case contact was successfully updated.' }
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

  def case_contact_params
    binding.pry
    form_params = params.require(:case_contact).permit(:occurred_at, :duration_minutes, :contact_type)
    binding.pry
    CaseContactParameters
      .new(form_params)
      .with_creator(current_user)
      .with_casa_case(current_user.casa_cases.first)
  end
end
