class LinePusher
  class << self
    def push_message(line_id, text_message)
      client.push_message(line_id, helper.pack_text_msg(text_message))
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
