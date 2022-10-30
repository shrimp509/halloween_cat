class CatConsumptionJob < ApplicationJob
  queue_as :default

  def perform(cat)
    return if cat.nil? || !cat.is_a?(Cat) || cat.leave?

    cat.saturation -= random_number(2, 5)
    cat.save

    if possibility_by_saturation?(cat.saturation)
      LinePusher.push_message(cat.room.line_id, "*#{cat.name}* : " + say_by_saturation(cat.saturation))
    end

    CatConsumptionJob.set(wait_until: random_number(5, 20).minutes.from_now).perform_later(cat)
  end

  private

  def possibility_by_saturation?(saturation)
    if saturation > 0 && saturation <= 20
      random_number(0, 2) == 0  # 1/2
    elsif saturation > 20 && saturation <= 50
      random_number(0, 3) == 0  # 1/3
    elsif saturation > 50 && saturation <= 80
      random_number(0, 7) == 0  # 1/7
    else
      random_number(0, 10) == 0  # 1/10
    end
  end

  def random_number(min, max)
    Random.rand(max) + min
  end

  def say_by_saturation(saturation)
    if saturation > 0 && saturation <= 20
      '(躺在地上四腳朝天) 朕...快...餓......ㄙ'
    elsif saturation > 20 && saturation <= 50
      '(走到你的腳邊蹭蹭) 喵 喵喵喵 (奴才，朕要吃東西了)'
    elsif saturation > 50 && saturation <= 80
      '(緩緩從眼角視線浮出) 恩... 是可以吃一點了拉，聽到了吧'
    else
      random_full_saturation_sentence
    end
  end

  def random_full_saturation_sentence
    ['(舔毛ing) ( Φ ω Φ )？', '(從螢幕前面飄過) Φ౪Φ', "(突然踩到你身上) ฅ●ω●ฅ"].sample
  end
end
