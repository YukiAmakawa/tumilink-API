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
    unless client.validates_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'].eql?('アンケート')
            client.reply_message(event['replyToken'], template)
          end
        end
      end

    }
    head: ok
  end

  private

    def template
      {
        "type": "template",
        "altText": "this is a confirm template",
        "template": {
          "type": "confirm",
          "text": "きのこの山とたけのこの里、おいしいのはどっち？",
            "actions": [
              {
                "type": "message",
                "label": "きのこの山",
                "text": "きのこの山"
              },
              {
                "type": "message",
                "label": "たけのこの里",
                "text": "たけのこの里"
              }
            ]
        }
      }
    end
end
