# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < ApplicationController
      # GET /api/v1/projects/:project_id/tasks
      def index
        project = Project.find(params[:project_id])
        tasks = project.tasks.by_position.includes(:assignees)
        
        # This sends the task data PLUS the array of assignees for each task
        render json: tasks.as_json(include: :assignees)
      end

      # POST /api/v1/projects/:project_id/tasks
      def create
        project = Project.find(params[:project_id])
        task = project.tasks.build(task_params)

        if task.save
          render json: task, status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/projects/:project_id/tasks/reorder
      def reorder
        task_ids = params[:task_ids]

        unless task_ids.is_a?(Array)
          return render json: { error: 'task_ids must be an array' }, status: :unprocessable_entity
        end

        project = Project.find(params[:project_id])

        ActiveRecord::Base.transaction do
          task_ids.each_with_index do |id, index|
            project.tasks.where(id: id).update_all(position: index)
          end
        end

        head :no_content
      end

      # PATCH /api/v1/tasks/:id
      def update
        task = Task.find(params[:id])

        if task.update(task_params)
          render json: task.as_json(include: :assignees)
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        task = Task.find(params[:id])
        task.destroy
        head :no_content
      end

      private

      def task_params
        params.require(:task).permit(:title, :description, :status, :start_date, :due_date, :parent_id)
      end
    end
  end
end