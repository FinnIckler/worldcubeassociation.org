# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsSubmission do
  let(:results_submission) { build(:results_submission) }

  it "is defines a valid factory" do
    expect(results_submission).to be_valid
  end

  it "requires message" do
    results_submission.message = nil
    expect(results_submission).to be_invalid_with_errors(message: ["can't be blank"])
  end

  it "requires confirmation" do
    results_submission.confirm_information = nil
    expect(results_submission).to be_invalid_with_errors(confirm_information: [ResultsSubmission::CONFIRM_INFORMATION_ERROR])
  end
end
