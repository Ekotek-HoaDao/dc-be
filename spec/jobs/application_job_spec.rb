require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'is a subclass of ActiveJob::Base' do
    expect(ApplicationJob).to be < ActiveJob::Base
  end

  it 'has sidekiq queue adapter configured' do
    expect(ApplicationJob.queue_adapter).to be_instance_of(ActiveJob::QueueAdapters::SidekiqAdapter)
  end
end
