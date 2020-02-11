# frozen_string_literal: true

class TranslationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      raise Pundit::NotAuthorizedError unless user.admin?

      Translation.all
    end
  end
end
