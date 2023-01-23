# frozen_string_literal: true

class ProfilePolicy < ApplicationPolicy
  def show?
    record.user == user && !user.phone_number_user?
  end

  def update?
    record.user == user && !user.phone_number_user?
  end
end
