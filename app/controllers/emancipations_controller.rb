class EmancipationsController < ApplicationController
  before_action :require_organization!
  after_action :verify_authorized
  ADD_CATEGORY = "add_category"
  ADD_OPTION = "add_option"
  DELETE_CATEGORY = "delete_category"
  DELETE_OPTION = "delete_option"
  SET_OPTION = "set_option"
  CHECK_ITEM_ACTIONS = [ADD_CATEGORY, ADD_OPTION, DELETE_CATEGORY, DELETE_OPTION, SET_OPTION].freeze

  def show
    @current_case = CasaCase.friendly.find(params[:casa_case_id])
    authorize @current_case
    @emancipation_form_data = EmancipationCategory.all

    respond_to do |format|
      format.html
      format.docx {
        template_filename = File.join("app", "documents", "templates", "emancipation_checklist_template.docx")
        @template = Sablon.template(File.expand_path(template_filename))

        html_body = EmancipationChecklistDownloadHtml.new(@current_case, @emancipation_form_data).call

        context = {
          case_number: @current_case.case_number,
          emancipation_checklist: Sablon.content(:html, html_body)
        }

        send_data((@template.render_to_string context, type: :docx), filename: "#{@current_case.case_number} Emancipation Checklist.docx")
      }
    end
  end

  def save
    authorize CasaCase, :save_emancipation?
    params.permit(:casa_case_id, :check_item_action)

    begin
      current_case = CasaCase.friendly.find(params[:casa_case_id])
      authorize current_case, :update_emancipation_option?
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Could not find case from id given by casa_case_id"}, status: :not_found
      return
    end

    unless current_case.in_transition_age?
      render json: {error: "The current case is not marked as transitioning"}, status: :bad_request
      return
    end
    check_item_action = params[:check_item_action]
    begin
      case check_item_action
      when ADD_CATEGORY
        current_case.add_emancipation_category(params[:check_item_id])
        render json: "success".to_json, status: :ok
      when ADD_OPTION
        current_case.add_emancipation_option(params[:check_item_id])
        render json: "success".to_json, status: :ok
      when DELETE_CATEGORY
        current_case.remove_emancipation_category(params[:check_item_id])
        current_case.emancipation_options.delete(EmancipationOption.category_options(params[:check_item_id]))
        render json: "success".to_json, status: :ok
      when DELETE_OPTION
        current_case.remove_emancipation_option(params[:check_item_id])
        render json: "success".to_json, status: :ok
      when SET_OPTION
        option = EmancipationOption.find(params[:check_item_id])
        current_case.emancipation_options.delete(EmancipationOption.category_options(option.emancipation_category_id))
        current_case.add_emancipation_option(params[:check_item_id])
        render json: "success".to_json, status: :ok
      else
        render json: {error: "Check item action: #{check_item_action} is not a supported action"}, status: :bad_request
      end
    rescue ActiveRecord::RecordInvalid
      render json: {error: "The record already exists as an association on the case"}, status: :bad_request
    rescue ActiveRecord::RecordNotFound
      render json: {error: "Tried to destroy an association that does not exist"}, status: :bad_request
    end
  end

  # Render a json error for json endpoints
  def not_authorized(exception)
    if exception.backtrace[2].end_with?("save'")
      render json: {error: "Sorry, you are not authorized to perform this action. Did the session expire?"}, status: :unauthorized
    else
      super()
    end
  end
end
