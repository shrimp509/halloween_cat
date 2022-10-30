class LineReplyer
  class << self
    COMMAND_PATTERN = /\A\/(?<command>\w+)(\s{1}(?<option>[\W\w]+))?\Z/

    def reply(events)
      events.each do |event|
        room_id = event['source']['groupId'] || event['source']['userId']

        replied = case event['type']
                  when 'join', 'follow'
                    Room.create(line_id: room_id)
                  when 'unfollow', 'leave'
                    Room.find_by(line_id: room_id)&.destroy
                  when 'message'
                    @room = Room.find_by(line_id: room_id)
                    @cat = @room.cat
                    next if @room.nil?
                    msg = event['message']['text']
                    next unless msg.first == '/'
                    match_result = msg.match(COMMAND_PATTERN)
                    next unless match_result
                    command = match_result['command']
                    option = match_result['option']
                    helper.pack_text_msg(deal_command(command, option))
                  end
        
        client.reply_message(event['replyToken'], replied) if replied
      end
    end

    private

    def helper
      Api::V1::WebhookController.helpers
    end

    def client
      helper.client
    end

    def deal_command(command, option)
      case command
      when 'help'
        '''
        遊戲指令：
        1. /help: 查詢所有可用指令
        2. /stat: 查詢主子狀態、遊戲進度
        3. /feed (罐罐名字): 餵食
        4. /play (互動名字): 互動
        5. /shop: 列出商店清單
        6. /buy (商品名稱): 消耗金錢購買玩具或食物
        7. /work: 列出打工清單，打工賺錢錢，才能買好料的伺候主子
        8. /work (工作名字): 開始工作了奴才，我要吃罐罐！
        9. /rank: 查詢積分排行榜
        10. /restart: 只有貓死了才能重新養一隻
        11. /storage: 可查看食物和玩具庫存（玩具每次使用，都有 10% 機率毀損）
        12. /rename: 替主子取名字
        '''.strip.gsub("        ", '')
      when 'stat'
        status = @cat.alive? ? '還活著' : '離家出走了'
        healthiness = if @cat.healthiness > 0 && @cat.healthiness <= 20
                        '快死了'
                      elsif @cat.healthiness > 20 && @cat.healthiness <= 50
                        '不太健康'
                      else
                        '很健康'
                      end
        trustiness = if @cat.trustiness > 0 && @cat.trustiness <= 20
                        '對奴才們很失望，快要離家出走了'
                      elsif @cat.trustiness > 20 && @cat.trustiness <= 50
                        '覺得奴才不太適任，正在考慮搬家'
                      elsif @cat.trustiness > 50 && @cat.trustiness <= 100
                        '慶幸奴才們終於有點上手了，孺子可教也，不錯不錯'
                      else
                        '很信任奴才們，繼續努力討好朕啊，朕會賞你們一個蹭蹭的'
                      end
        saturation = if @cat.saturation > 0 && @cat.saturation <= 20
                        '朕快餓了死拉，是真的會死的那種，快來人啊 (｡í_ì｡)'
                      elsif @cat.saturation > 20 && @cat.saturation <= 50
                        '好餓... 好餓...'
                      elsif @cat.saturation > 50 && @cat.saturation <= 80
                        '下一餐要吃什麼好呢？ 你說呢奴才們？'
                      else
                        '我好飽，朕要先去休息了'
                      end
        """
        ♥️ 狀態：#{@cat.name} #{status}，#{healthiness}，#{trustiness}，#{saturation}
        💰 錢錢：#{@room.money}
        📈 總分：#{@room.score}
        """.strip.gsub("        ", '')
      when 'feed'
        return "#{@cat.name} 已受不了而離家出走，在你的世界裡消失，考慮 /restart 重養一隻？" if @cat.leave?
        return "沒有這種東西哦，你是不是想壞壞 -`д´-" unless @room.items.pluck(:name).include?(option)
        @item = @room.items.find_by(name: option)
        return "這東西不能吃... 可憐的人類(´･_･`)" unless @item.item_type == 'food'
        return "你們的 #{option} 數量不夠，殘念爹斯 (´ー`)" if @item.count <= 0
        item_preference = @cat.cat_item_preferences.find_by(item: @item).like
        key = item_preference ? 'like' : 'dont-like'
        food_effect = Item.get_attr(option)&.dig('effect', key)
        @cat.saturation += food_effect['saturation']
        @cat.trustiness += food_effect['trustiness']
        @cat.healthiness += food_effect['healthiness']
        @cat.save
        @room.increment!(:score, food_effect['score'])
        @item.decrement!(:count)
        item_preference ? 'ヽ(=^･ω･^=)丿' : '( Φ ω Φ )'
      when 'play'
        return "#{@cat.name} 已受不了而離家出走，在你的世界裡消失，考慮 /restart 重養一隻？" if @cat.leave?
        return "沒有這種東西哦，你是不是想壞壞 -`д´-" unless @room.items.pluck(:name).include?(option)
        @item = @room.items.find_by(name: option)
        return "這東西不是用來用的... 可憐的人類(´･_･`)" unless @item.item_type == 'toy'
        return "你們的 #{option} 數量不夠，殘念爹斯 (´ー`)" if @item.count <= 0
        item_preference = @cat.cat_item_preferences.find_by(item: @item).like
        key = item_preference ? 'like' : 'dont-like'
        toy_effect = Item.get_attr(option)&.dig('effect', key)
        @cat.saturation += toy_effect['saturation']
        @cat.trustiness += toy_effect['trustiness']
        @cat.healthiness += toy_effect['healthiness']
        @cat.save
        @room.increment!(:score, toy_effect['score'])
        @item.decrement!(:count)
        item_preference ? 'ヽ(=^･ω･^=)丿' : '( Φ ω Φ )'
      when 'shop'
        items = Item.all_items.map do |item| 
          sliced_item = item.slice('name', 'price', 'introduction', 'item_type')
          "#{sliced_item['item_type'] == 'food' ? '🍖' : '🧸'} *#{sliced_item['name']}* : #{sliced_item['price']} 元\n#{sliced_item['introduction']}"
        end
        "歡迎光臨貓貓商店～\n`購買範例：/buy 罐罐`\n購買前請先確認錢錢餘額夠不夠哦～\n\n" + items.join("\n\n")
      when 'buy'
        return "請輸入購買項目" if option.nil?
        item_attr = Item.get_attr(option)
        return "沒有這個商品哦" if item_attr.nil?
        return "*#{@cat.name}* : 奴才你買不起，還不趕快去賺錢 (╯•̀ὤ•́)╯" if item_attr['price'] > @room.money
        item = @room.items.find_by(name: option)
        item.increment!(:count)
        @room.decrement!(:money, item_attr['price'])
        "耶～購買成功，買東西的時候最快樂了，您的 *#{option}* 有 #{item.count} 個，您的餘額還有 *#{@room.money}* 元"
      when 'work'
        works = WorksGetter.all
        if option.nil? || option.blank?
          result = works.map do |work|
            "🐶 *#{work['name']}* 可以賺 #{work['can_earn']} 元"
          end
          return "工作清單：\n\n"+ result.join("\n")
        end
        
        return "*#{@room.cat.name}* : 沒有這種工作，你到底在想什麼 (´･_･`)" unless works.pluck('name').include?(option)
        work = works.select {|work| work['name'] == option }&.last
        @room.increment!(:money, work['can_earn'])
        "*#{@room.cat.name}* : 很好，現在你有 #{@room.money} 元了，快去買我要的東西，快 ヽ(●´∀`●)ﾉ"
      when 'rank'
        ranking_result = Room.ranking(10).each_with_index.map do |room, index|
          "第 *#{index + 1}* 名: *#{room.room_name}* 養的 *#{room.cat.name}* : *#{room.score}* 分"
        end
        "風雲榜：\n\n" + "#{ranking_result.join("\n")}"
      when 'restart'
        return "#{@cat.name} 還健康得很，請好好服侍牠" unless @cat.healthiness < 0
        room_id = @room.line_id
        @room.destroy
        new_room = Room.create(line_id: room_id)
        "(已全部重置) #{new_room.cat.name}: 你... 是誰？"
      when 'storage'
        items = @room.existing_items.map do |item|
          "➕ #{item.name}: #{item.count} 個"
        end

        if items.blank?
          "*#{@cat.name}* : 倉庫沒東西，奴才們在幹嘛，別偷懶啊！"
        else
          "*倉庫庫存* :\n" + items.join("\n")
        end
      when 'rename'
        return "#{@cat.name} 已受不了而離家出走，在你的世界裡消失，考慮 /restart 重養一隻？" if @cat.leave?
        name_pattern = /\A(.{1,50})\z/
        return "*#{@cat.name}* : 你真的有想要給我取名字嗎 ...?\n" + "(系統溫馨提醒: `/rename 要改的名字` )" if option.nil? || option.blank?
        result = @cat.update(name: option) if option.match?(name_pattern)
        result ? "*#{@cat.name}* : 這名字... 好拉，還能接受" : '朕，不給改'
      end
    end
  end
end
