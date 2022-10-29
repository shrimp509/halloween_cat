class Api::V1::WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  COMMAND_PATTERN = /\A\/(?<command>\w+)(\s{1}(?<option>\w+))?\Z/

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    events = helpers.client.parse_events_from(body)
    LineReplyer.reply(events)
    'OK'
  end
end
