class LineReplyer
  class << self
    COMMAND_PATTERN = /\A\/(?<command>\w+)(\s{1}(?<option>\w+))?\Z/

    def reply(events)
      events.each do |event|
        next unless event.is_a?(Line::Bot::Event::Message)
        next unless event.type == Line::Bot::Event::MessageType::Text
        msg = event['message']['text']
        next unless msg.first == '/'
        match_result = msg.match(COMMAND_PATTERN)
        next unless match_result
        command = match_result['command']
        option = match_result['option']
        
        roomId = event['source']['groupId'] || event['source']['userId']
        
        client.reply_message(event['replyToken'], helper.pack_text_msg("#{roomId}: #{command} #{option} valid"))
      end
    end

    private

    def helper
      Api::V1::WebhookController.helpers
    end

    def client
      helper.client
    end
  end
end
