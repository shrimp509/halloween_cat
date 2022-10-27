class Api::V1::WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  COMMAND_PATTERN = /\A\/(?<command>\w+)(\s{1}(?<option>\w+))?\Z/

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    events = helpers.client.parse_events_from(body)
    # LineReplyer.reply(events)
    events.each do |event|
      msg = event['message']['text']
      match_result = msg.match(COMMAND_PATTERN)
      next unless match_result
      command = match_result['command']
      option = match_result['option']
      
      roomId = event['source']['groupId'] || event['source']['userId']
      helpers.client.reply_message(event['replyToken'], helpers.pack_text_msg("#{roomId}: #{command} #{option} valid"))
    end
    'OK'
  end
end
