require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  it 'is an abstract class' do
    expect(ApplicationRecord).to be < ActiveRecord::Base
  end

  it 'is defined' do
    expect(ApplicationRecord).to be_a(Class)
  end
end
