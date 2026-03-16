# frozen_string_literal: true

class BaseSerializer
  def initialize(object)
    @object = object
  end

  def as_json
    raise NotImplementedError, 'Subclasses must implement as_json method'
  end

  private

  attr_reader :object
end
