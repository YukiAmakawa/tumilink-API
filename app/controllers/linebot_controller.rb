class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if URI.regexp.match(event.message['text']) != nil
            @@url = event.message['text']
            client.reply_message(event['replyToken'], template)
          elsif event.message['text'] == "保存する" || "キャンセル"
              line_id = event['source']["userId"]
              user = User.find_by(line_id: event['source']["userId"])
              if user.nil?
                user = User.create(line_id: line_id)
              end
              user.contents.create(url: @@url)
          end
        end
      end
    }

    head :ok
  end

  private

    def template
      {
        "type": "template",
        "altText": "this is a confirm template",
        "template": {
            "type": "confirm",
            "text": "この記事を保存しますか？",
            "actions": [
                {
                  "type": "message",
                  "label": "保存する",
                  "text": "保存する"
                },
                {
                  "type": "message",
                  "label": "キャンセル",
                  "text": "キャンセル"
                }
            ]
        }
      }
    end
end