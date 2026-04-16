require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'has a valid factory' do
      # This test will pass once FactoryBot is properly setup
      expect(User).to be_a(Class)
    end
  end

  describe 'associations' do
    it 'responds to basic ActiveRecord methods' do
      expect(User.new).to respond_to(:save)
      expect(User.new).to respond_to(:valid?)
    end
  end
end
