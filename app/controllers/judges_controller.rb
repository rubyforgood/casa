class JudgesController < ApplicationController
  before_action :set_judge, except: [:new, :create]
  after_action :verify_authorized

  def new
    authorize Judge
    @judge = Judge.new
  end

  def create
    authorize Judge
    @judge = Judge.new(judge_params)

    if @judge.save
      redirect_to edit_casa_org_path(current_organization), notice: "Judge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @judge
  end

  def update
    authorize @judge
    if @judge.update(judge_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Judge was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_judge
    @judge = Judge.find(params[:id])
  end

  def judge_params
    params.require(:judge).permit(:name, :active).merge(
      casa_org: current_organization
    )
  end
end
