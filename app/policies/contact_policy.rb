# frozen_string_literal: true

class ContactPolicy < ApplicationPolicy
  def create?
    true
  end
end
