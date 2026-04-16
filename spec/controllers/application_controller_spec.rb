require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  it 'responds to basic methods' do
    expect(ApplicationController.new).to be_a(ActionController::API)
  end

  it 'is defined as an API controller' do
    expect(ApplicationController.ancestors).to include(ActionController::API)
  end
end
