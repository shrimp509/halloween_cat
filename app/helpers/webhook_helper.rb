module WebhookHelper
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = Rails.application.credentials.line.channel_id
      config.channel_secret = Rails.application.credentials.line.channel_secret
      config.channel_token = Rails.application.credentials.line.channel_token
    }
  end

  def pack_text_msg(message)
    { type: 'text', text: message }
  end

  def pack_jable_flex_msg(object_info)
    {
      type: 'flex',
      altText: "新片上架 #{object_info[:actress]} ",
      contents: pack_flex_content_of_jable(object_info)
    }
  end

  def pack_flex_content_of_jable(object_info)
    {
      "type": "bubble",
      "hero": {
        "type": "video",
        "url": object_info[:short_video],
        "previewUrl": object_info[:thumbnail],
        "altContent": {
          "type": "image",
          "size": "full",
          "aspectRatio": "20:13",
          "aspectMode": "cover",
          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png"
        },
        "aspectRatio": "16:9"
      },
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": object_info[:actress],
            "weight": "bold",
            "size": "lg"
          },
          {
            "type": "image",
            "url": object_info[:thumbnail],
            "size": "full",
            "aspectRatio": "16:9"
          },
          {
            "type": "box",
            "layout": "vertical",
            "margin": "lg",
            "spacing": "sm",
            "contents": [
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "標題",
                    "color": "#aaaaaa",
                    "size": "sm",
                    "flex": 1
                  },
                  {
                    "type": "text",
                    "text": object_info[:title],
                    "wrap": true,
                    "color": "#666666",
                    "size": "sm",
                    "flex": 5
                  }
                ]
              },
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "番號",
                    "color": "#aaaaaa",
                    "size": "sm",
                    "flex": 1
                  },
                  {
                    "type": "text",
                    "text": object_info[:uuid].to_s,
                    "wrap": true,
                    "color": "#666666",
                    "size": "sm",
                    "flex": 5
                  }
                ]
              },
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "時長",
                    "color": "#aaaaaa",
                    "size": "sm",
                    "flex": 1
                  },
                  {
                    "type": "text",
                    "text": object_info[:length].to_s,
                    "wrap": true,
                    "color": "#666666",
                    "size": "sm",
                    "flex": 5
                  }
                ]
              },
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "觀看",
                    "color": "#aaaaaa",
                    "size": "sm",
                    "flex": 1
                  },
                  {
                    "type": "text",
                    "text": object_info[:views].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
                    "wrap": true,
                    "color": "#666666",
                    "size": "sm",
                    "flex": 5
                  }
                ]
              },
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "喜歡",
                    "color": "#aaaaaa",
                    "size": "sm",
                    "flex": 1
                  },
                  {
                    "type": "text",
                    "text": object_info[:likes].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
                    "wrap": true,
                    "color": "#666666",
                    "size": "sm",
                    "flex": 5
                  }
                ]
              }
            ]
          }
        ]
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "spacing": "sm",
        "contents": [
          {
            "type": "button",
            "style": "link",
            "height": "sm",
            "action": {
              "type": "uri",
              "label": "WATCH",
              "uri": object_info[:full_video]
            }
          }
        ],
        "flex": 0
      }
    }
  end

  def pack_nhentai_flex_msg(objects)
    {
      "type": "flex",
      "altText": "新漫畫",
      "contents": {
        "type": "carousel",
        "contents": objects.map { |obj| pack_carousel_content(obj) }
      }
    }
  end

  def pack_carousel_content(object)
    {
      type: 'bubble',
      hero: {
        "type": "image",
        "size": "full",
        "aspectMode": "fit",
        "url": object.cover
      },
      body: {
        "type": "box",
        "layout": "vertical",
        "spacing": "sm",
        "contents": [
          {
            "type": "text",
            "text": object.uuid.to_s,
            "wrap": true,
            "weight": "bold",
            "size": "xl",
            "style": "normal",
            "align": "center"
          }
        ]
      },
      footer: {
        "type": "box",
        "layout": "vertical",
        "spacing": "sm",
        "contents": [
          {
            "type": "button",
            "style": "primary",
            "action": {
              "type": "uri",
              "label": "WATCH",
              "uri": object.goto
            }
          }
        ]
      }
    }
  end
end
