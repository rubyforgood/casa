class ContactTopicAnswersController < ApplicationController
  def create
    @contact_topic_answer = ContactTopicAnswer.new(contact_topic_answer_params)
    authorize @contact_topic_answer

    respond_to do |format|
      if @contact_topic_answer.save
        format.json { render json: @contact_topic_answer.as_json, status: :created }
      else
        format.json { render json: @contact_topic_answer.errors.as_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact_topic_answer = ContactTopicAnswer.find(params[:id])
    authorize @contact_topic_answer

    @contact_topic_answer.destroy!

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def contact_topic_answer_params
    params.require(:contact_topic_answer)
      .permit(:id, :contact_topic_id, :case_contact_id, :value, :_destroy)
  end
end
