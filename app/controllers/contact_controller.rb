# frozen_string_literal: true

class ContactController < ApplicationController
  before_action :redirect_to_www

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new
    if @contact.update(contact_params)
      ContactMailer.email(@contact.id).deliver_later
      redirect_to root_path(subdomain: 'www'), notice: 'Thank you for your interest!  We will be in contact shortly.'
    else
      render :new
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :organization, :city, :state, :email, :phone, :comments)
  end
end
