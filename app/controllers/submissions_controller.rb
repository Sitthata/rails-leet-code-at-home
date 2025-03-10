class SubmissionsController < ApplicationController
  def new
    @submission = Submission.new
  end

  def create
    @submission = Submission.new(submission_params)
  end

  private
  def submission_params
    params.expect(submission: [ :code ])
  end
end
