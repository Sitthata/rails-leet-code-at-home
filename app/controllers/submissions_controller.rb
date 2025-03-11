require "open3"

class SubmissionsController < ApplicationController
  def show
    @submission = Submission.find(params[:id])
  end

  def new
    @submission = Submission.new
  end

  def execute
    @submission = Submission.new(submission_params)
    @submission.status = "pending"

    file_name = "submission_#{Time.now.strftime('%Y%m%d%H%M%S')}.rb"
    file_path = File.join(Rails.root, "tmp", file_name)

    begin
      File.write(file_path, @submission.code)

      commands = [
        "docker", "run", "--rm",
        "--name", "ruby_executor_#{Time.now.strftime('%Y%m%d%H%M%S')}",
        "-v", "#{file_path}:/app/test.rb",
        "--cpus=0.5",
        "ruby:3.3-alpine",
        "ruby", "/app/test.rb"
      ]
      stdout, stderr, status = run_commands(commands)

      if status.success?
        @submission.result = stdout
        @submission.status = "success"
      else
        @submission.result = stderr
        @submission.status = "error"
      end

      @result = @submission.result

      render "submissions/new"
    rescue => e
      @submission.status = "error"
      @submission.result = e.message
      @result = @submission.result
      render "submissions/new"
    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end

  def create
    @submission = Submission.new(submission_params)

    if @submission.save
      redirect_to @submission, notice: "Submission was successfully saved."
    else
      render "submissions/new", status: :unprocessable_entity
    end
  end

  private
  def submission_params
    params.require(:submission).permit(:code, :status, :result)
  end

  def run_commands(command)
    stdout, stderr, status = Open3.capture3(*command)
    return stdout, stderr, status
  end
end
