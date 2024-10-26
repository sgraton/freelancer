class RequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_request, except: [:new, :create, :index, :list, :my_offers]
  before_action :is_authorised, only: [:edit, :update, :destroy, :offers]
  before_action :set_categories, only: [:new, :edit, :list]

  def index
    @requests = current_user.requests
  end

  def new
    @request = current_user.requests.build
  end

  def create
    @request = current_user.requests.build(request_params)
    if @request.save
      redirect_to requests_path, notice: "Sauvé..."
    else
      redirect_to request.referrer, flash: {error: @request.errors.full_messages.join(', ')}
    end
  end

  def edit
  end

  def update
    if @request.update(request_params)
      redirect_to requests_path, notice: "Sauvé..."
    else
      redirect_to request.referrer, flash: {error: @request.errors.full_messages.join(', ')}
    end
  end

  def show
  end

  def destroy
    @request.destroy
    redirect_to requests_path, notice: "Supprimé..."
  end

  def list
    @category_id = params[:category]

    if @category_id.present?
      @requests = Request.where(category_id: @category_id)
    else
      @requests = Request.all
    end
  end

  def offers
    @offers = @request.offers
  end

  def my_offers
    @offers = current_user.offers
  end

  private

  def set_categories
    @categories = Category.where(active: true)
  end

  def set_request
    @request = Request.find(params[:id])
  end

  def is_authorised
    redirect_to root_path, alert: "Vous n'avez pas l'autorisation" unless current_user.id == @request.user_id
  end
  
  def request_params
    params.require(:request).permit(:description, :category_id, :delivery, :budget, :attachment_file, :title)
  end
end
