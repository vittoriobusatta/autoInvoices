require 'dotenv/load'
class WebhooksController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def receive

    puts ENV['CLOUDCONVERT_WEBHOOK_SECRET']

    head :ok
  end
end
