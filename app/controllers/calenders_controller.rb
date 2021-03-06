class CalendersController < ApplicationController
  before_action :set_calender, only: [:edit, :update, :destroy, :events, :update_events]
  before_action :authenticate_user!, only: [:new, :events, :update_events]

  # GET /calenders
  # GET /calenders.json
  def index
    @calenders = Calender.where('name like ?', "%#{params[:q]}%").all
  end

  # GET /calenders/1
  # GET /calenders/1.json
  def show
    @calender = Calender.find(params[:id])
    respond_to do |format|
      format.html{ render }
      format.ics do
        response.headers['Content-Disposition'] = %Q(attachment; filename="#{@calender.name}.ics")
        render text: @calender.to_ics
      end
    end
  end

  # GET /calenders/new
  def new
    @calender = current_user.calenders.new
  end

  # GET /calenders/1/edit
  def edit
  end

  # POST /calenders
  # POST /calenders.json
  def create
    @calender = current_user.calenders.new(calender_params)

    respond_to do |format|
      if @calender.save
        format.html { redirect_to user_path(current_user), notice: '日曆成功的新增了' }
        format.json { render :show, status: :created, location: @calender }
      else
        format.html { render :new }
        format.json { render json: @calender.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /calenders/1
  # PATCH/PUT /calenders/1.json
  def update
    respond_to do |format|
      if @calender.update(calender_params)
        format.html { redirect_to @calender, notice: '日曆成功的更新了' }
        format.json { render :show, status: :ok, location: @calender }
      else
        format.html { render :edit }
        format.json { render json: @calender.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calenders/1
  # DELETE /calenders/1.json
  def destroy
    @calender.archive
    respond_to do |format|
      format.html { redirect_to calenders_url, notice: '日曆成功的刪除了' }
      format.json { head :no_content }
    end
  end

  # GET /calendars/:calender_id/events
  def events
  end

  # PUT /calendars/:calender_id/events
  def update_events
    @calender.assign_attributes params.require(:calender).permit(events_attributes: [:id, :title, :start, :end, :all_day, :_destroy])
    @calender.events.each{ |event| event.user = current_user if event.user.nil? }
    if @calender.save
      redirect_to @calender, notice: '更新成功！'
    else
      render :events
    end
  end

  def embeded
    render partial: 'calendar', layout: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calender
      @calender = Calender.find(params[:id] || params[:calender_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calender_params
      params.require(:calender).permit(:user_id, :name, :public)
    end
end
