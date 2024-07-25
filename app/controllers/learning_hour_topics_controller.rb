class LearningHourTopicsController < ApplicationController
  before_action :set_learning_hour_topic, only: %i[edit update]
  after_action :verify_authorized

  def new
    authorize LearningHourTopic
    @learning_hour_topic = LearningHourTopic.new
  end

  def edit
    authorize @learning_hour_topic
  end

  def create
    authorize LearningHourTopic
    @learning_hour_topic = LearningHourTopic.new(learning_hour_topic_params)

    if @learning_hour_topic.save
      redirect_to edit_casa_org_path(current_organization), notice: "Learning Topic was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @learning_hour_topic

    if @learning_hour_topic.update(learning_hour_topic_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Learning Topic was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_learning_hour_topic
    @learning_hour_topic = LearningHourTopic.find(params[:id])
  end

  def learning_hour_topic_params
    params.require(:learning_hour_topic).permit(:name, :active).merge(
      casa_org: current_organization
    )
  end
end
