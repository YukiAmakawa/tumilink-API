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
        handle_message_event(event)
      end
    }

    head :ok
  end

  private

    def handle_message_event(event)
      case event.type
      when Line::Bot::Event::MessageType::Text
        handle_text_event(event)
      end
    end

    def handle_text_event(event)
      @@url = nil
      # urlが投稿された場合
      if URI.regexp.match(event.message['text']) != nil
        handle_url_text(event)
      # urlを保存するかどうかのLINEテンプレートに対する回答
      elsif event.message['text'] == "保存する" || "キャンセル"
        handle_template_answer(event)
      end
    end

    def handle_url_text(event)
      @@url = event.message['text']
      client.reply_message(event['replyToken'], template_save_content)
    end

    def handle_template_answer(event)
      client.reply_message(event['replyToken'], message_text_only("先に保存したい記事のURLを教えてね")) if @@url == nil
      return true if event.message['text'] == "キャンセル"

      line_id = event['source']["userId"]

      user = User.find_by(line_id: event['source']["userId"])
      content = Content.find_by(url: @@url)

      if user.nil?
        user = User.create(line_id: line_id)
      end
      if content.nil?
        content = Content.create(url: @@url)
      end

      if UserContent.find_by(user_id: user.id, content_id: content.id) != nil
        client.reply_message(event['replyToken'], message_text_only("この記事はすでに保存されていますよ！"))
      else
        UserContent.create(user_id: user.id, content_id: content.id)
        client.reply_message(event['replyToken'], message_text_only("記事を保存しました"))
      end
    end

    def template_save_content
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

    def message_text_only(text)
      {
        "type": "text",
        "text": text
      }
    end
end