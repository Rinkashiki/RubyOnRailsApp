class ClipsController < ApplicationController

  layout 'in_session', only: [ :index, :show, :new]

  before_action :authorized 
  
  def index
    @clips = Clip.all
  end

  def new
    @clip = Clip.new
  end

  def create  
    @clip = Clip.new clip_params
    @clip[ :clipName] = File.basename(params[ :clip][ :video].original_filename, '.mp4').truncate(20)
    @clip[ :uploadUser] = helpers.current_user[ :name]

    # Save clips in DB
    if @clip.save
      flash[ :alert] = 'Successfully uploaded video'
      redirect_to clips_path
    else
      flash[ :alert] = c.errors.first.full_message
      redirect_to new_clip_path
    end
  end 

  def show
    @clip = Clip.find params[ :id]
  end

  private 

  def clip_params
    params.require( :clip).permit( :video)
  end

end
