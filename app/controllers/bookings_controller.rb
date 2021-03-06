class BookingsController < ApplicationController
  require 'bike_decorator'
  before_filter :authenticate_user!
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  
  # GET /bookings
  # GET /bookings.json
  def index
    @user = User.find(params[:user_id])
    @bookings = @user.bookings
   
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    @user = User.find(params[:user_id])
     
    @booking = @user.bookings.find(params[:id])

    @bikes=Bike.all



 def paymentdone
  # Amount in cents
 

  customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :source  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :customer    => customer.id,
    :amount      => @amount,
    :description => 'Rails Stripe customer',
    :currency    => 'eur'
  )

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to '/paymentdone'
  end

   
  end

  # GET /bookings/new
  def new

     @user = User.find(params[:user_id])
       #@booking = @user.booking.find(params[:id])
     @booking=@user.bookings.build
     @bikes=Bike.all

  end
 
  # GET /bookings/1/edit
  def edit
    @user = User.find(params[:user_id])
    @booking=@user.bookings.find(params[:id])
    @bikes=Bike.all
  end
  def summary
  end

  # POST /bookings
  # POST /bookings.json
  def create
       #find the the current user id and is asociate with the booking table
      @user = User.find(params[:user_id])
      #get the params to create a new booking
      @booking = Booking.new(booking_params)
        #allow params to be save in table bookings and require all of them
      @booking = @user.bookings.build(params.require(:booking).permit!)
      @booking=@user.bookings.build(params.require(:booking).permit(:start, :return, :addons, :noaddons, :bike_id))
      # if bike_id is nil the app will redirect the user back to the booking page and display a messsage to the user "pick a bike available please"
      if @booking.bike_id.nil? or @booking.bike.status== false
      #redifect user to the new booking page
     redirect_to new_user_booking_path(current_user.id), notice: 'Pick a bike available please!' 
      else 
        #otherwise evaluate if the dates are valid
  if @booking.start < Date.current or  @booking.return < @booking.start  
     redirect_to new_user_booking_path(current_user.id), notice: 'Cannot complete booking wrong dates !'
  else
    #if dates are valid atribute quantity is update
       @booking.bike.quantity+= -1
       #calculate the period of the booking to calculate the global amount
       @period = @booking.return.day-@booking.start.day + 1
      #this code set a bike to false if the status value is false when the quantity is zero
    if @booking.bike.quantity == 0
      #set value of status to false to make a bike unavailable
       @booking.bike.status= false
    end
 
       #send the value to the decorator create in the lib folder bike_decorator.rb 
      myBike = BasicBike.new(@booking.bike.price, @booking.bike.quantity, @booking.bike.category)
     # add the extra features to the new bike
        #if the user pick a helmet as a extra the total amount is update adding the extracost of the global amount 
      if params[:bike][:helmet].to_s.length > 0 then
      myBike = HelmetDecorator.new(myBike)
      end
      #if the user pick ligths mybike send values to get the extra cost of the addon
      if params[:bike][:ligths].to_s.length > 0 then
      myBike = LigthsDecorator.new(myBike)
      end
      if params[:bike][:basket].to_s.length > 0 then
      myBike = BasketDecorator.new(myBike)
      end
      #update the total to pay by multiplying the cost of the bike by the period  of the booking
      @booking.total = myBike.cost * @period
      #the addon atribute is update also with the extra featurees picked  by the user
      @booking.addons = myBike.details

     respond_to do |format|
      if @booking.save
        format.html { redirect_to user_booking_path(@user,@booking), notice: 'Booking was successfully created.' }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end
end
end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    @user = User.find(params[:user_id])
    @booking= Booking.find(params[:id])
     
  
  if @booking.start < Date.current or  @booking.return < @booking.start
 redirect_to edit_user_booking_path(current_user.id), notice: 'Cannot complete booking please check Dates' 
      
         else
          respond_to do |format|

            
      if @booking.update_attributes(params.require(:booking).permit(:start,:return, :bike_id))
        format.html { redirect_to user_booking_url(@user,@booking), notice: 'Booking was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end
end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @user = User.find(params[:user_id])
    @booking= Booking.find(params[:id])

    @booking.destroy
    respond_to do |format|
      format.html { redirect_to user_bookings_path(@user), notice: 'Booking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:start, :return, :addons,:bike_id)
    end
end
