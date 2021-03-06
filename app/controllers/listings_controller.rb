class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_user, except: [:index, :show]

  # GET /listings
  # GET /listings.json
  def index
    if params[:category].blank?
      @listings = Listing.all.paginate(:page => params[:page], :per_page => 12)
    else
      @category_id = Category.find(params[:category]).id
      @listings = Listing.where(category_id: @category_id).order("created_at DESC").paginate(:page => params[:page], :per_page => 12)
    end
  end


  # GET /listings/1
  # GET /listings/1.json


  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)

    respond_to do |format|
      if @listing.save

        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to root_url, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # Show the reviews under each restaurant by decending order, also takes care of the blank reviews.
    
    def show
      @reviews = Review.where(listing_id: @listing.id).order("created_at DESC")
      if @reviews.blank?
        @avg_rating = 0
      else
        @avg_rating = @reviews.average(:rating).round(2)
      end
      @notifications = Notification.all
    end


  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    def check_user
    unless current_user.admin?
        redirect_to root_url, alert: "Sorry! You will need to have reviewed atleast 5 items to get enough points to request for reviews, Put in some effort!", class: "btn btn-danger"
    end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:image, :name, :description, :address, :phone, :email, :website, :title, :category_id)
    end
end
