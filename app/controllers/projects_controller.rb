class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :follow, :unfollow, :like, :unlike]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy

    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  # PATCH/PUT /follow
  def follow
    current_user.followed_projects << @project

    if current_user.save
      redirect_to @project, notice: "You're following the project."
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to @project, notice: "You're already following the project."
  end

  # PATCH/PUT /follow
  def unfollow
    if current_user.followed_projects.include?(@project)
      current_user.followed_projects.delete(@project)
      current_user.save
    end

    redirect_to @project, notice: "You're not following the project."
  end

  # PATCH/PUT /like
  def like
    current_user.liked_projects << @project

    if current_user.save
      redirect_to project_path, notice: 'You liked the project.'
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to @project, notice: 'You already liked the project.'
  end

  # PATCH/PUT /like
  def unlike
    if current_user.liked_projects.include?(@project)
      current_user.liked_projects.delete(@project)
      current_user.save
    end

    redirect_to @project, notice: "You're not liking the project."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(
      :name,
      :client_id,
      :description,
      :scm_type,
      :scm_reference,
      :image,
      technology_ids: [],
      members_attributes: [:id, :person_id, :role_id, :period_start, :period_end, :_destroy],
      screenshots_attributes: [:id, :image, :description, :_destroy])
  end
end
