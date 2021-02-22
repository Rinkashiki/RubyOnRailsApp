class ClipsController < ApplicationController

  layout 'in_session', only: [ :index, :show, :new, :edit, :add_topic]

  before_action :authorized 

  before_action :set_clip, only: [ :show, :destroy, :edit, :update, :add_topic, :add_topic_post]
  
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
      redirect_to new_clip_path
    else
      flash[ :alert] = @clip.errors.first.full_message
      redirect_to new_clip_path
    end
  end 

  def show
    if !@clip[ :decision_id].nil?
      @decision = Decision.find(@clip[ :decision_id])
    end
    if !@clip[ :sanction_id].nil?
      @sanction = Sanction.find(@clip[ :sanction_id])
    end
    
    query = "SELECT topics.id, topics.description FROM topics JOIN clip_topic ON clip_topic.topics_id = topics.id WHERE clip_topic.clips_id = '#{@clip.id}'"

    @topics = ActiveRecord::Base.connection.exec_query(query)
    
    #@topics = Topic.all
  end

  def edit
    @decisions = Decision.all
    @sanctions = Sanction.all
  end

  def update
    @decision = Decision.find_by_description(params[ :clip][ :decision])
    @sanction = Sanction.find_by_description(params[ :clip][ :sanction])

    @clip.update(decision_id: @decision[ :id], sanction_id: @sanction[ :id])

    flash[ :alert] = 'Succesfully edited!'

    redirect_to @clip
  end

  def destroy
    @clip.destroy
    flash[ :alert] = 'Successfully deleted clip'
    redirect_to clips_path
  end

  def add_topic
    @topics = Topic.all
  end

  def add_topic_post

    query = "INSERT into clip_topic (clips_id, topics_id, created_at, updated_at) 
    values ('#{@clip.id}', '#{params[ :topic].id}', now(), now())"

    ActiveRecord::Base.connection.exec_query(query)

  end

  def quit_topic
    @topic = Topic.find params[ :topic]

    query = "DELETE from clip_topic where clips_id = '#{@clip.id}', topics_id = '#{@topic.id}'"
    ActiveRecord::Base.connection.exec_query(query)
    
    flash[ :alert] = 'Successfully quit topic'
    redirect_to clip_path
  end

  private 

  def clip_params
    params.require( :clip).permit( :video)
  end

  def set_clip
    @clip = Clip.find params[ :id]
  end

end
