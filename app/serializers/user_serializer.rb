# frozen_string_literal: true

class UserSerializer < BaseSerializer
  def as_json
    {
      id: object.id,
      email: object.email,
      name: object.name,
      active: object.active,
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
