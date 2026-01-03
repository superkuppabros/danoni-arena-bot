require 'discordrb'
require 'dotenv'
require_relative './service/resultService.rb'
require_relative './service/cardService.rb'

Dotenv.load
_bot_token = ENV["BOT_TOKEN"]
bot = Discordrb::Bot.new(token: _bot_token)

bot.register_application_command(:countdown, "カウントダウンを開始します") do |cmd|
  cmd.integer(:seconds, "カウントダウンする秒数(3-30)", required: false)
end

bot.register_application_command(:dice, "ダイスを振ります") do |cmd|
  cmd.string(:roll, "振るダイスの形式 (例: 2d6)", required: false)
end

bot.application_command(:countdown) do |event|
  puts "[INFO] /countdown event.options: #{event.options.inspect}"

  seconds = event.options["seconds"] || 3

  if seconds > 30
    event.respond(content: "秒数が大きすぎます。", ephemeral: true)
    next
  end

  if seconds < 3
    seconds = 3
  end

  # 応答を遅延させる
  event.defer

  for i in 0..seconds do
    rest = seconds - i
    if i == 0 || rest % 10 == 0 || rest <= 3
      event.channel.send_message("#{rest}")
    end
    sleep(1)
  end
end

@mode = "arena"
bot.message(content: '!mode a') do |event|
  @mode = "arena"
  event.respond "モードをアリーナに設定しました。"
end
bot.message(content: '!mode s') do |event|
  @mode = "speedtwister"
  event.respond "モードをスピードツイスターに設定しました。"
end

bot.message(contains: '#danoni') do |event|
  result_service = ResultService.new
  author = event.author.display_name.to_s
  return_message = ""

  if @mode == "speedtwister"
    result = result_service.speedTwisterResult(event.message.to_s)
    return_message = "#{author}さんのプレイ結果\n" + result
  else
    result = result_service.arenaResult(event.message.to_s)
    return_message = "Player: #{author}\n" + result
  end
  event.respond return_message
end

# /dice 1d6 でダイスを振れる
bot.application_command(:dice) do |event|
  puts "[INFO] /dice event.options: #{event.options.inspect}"

  arg = event.options["roll"] || "1d6"
  line = arg.split("d")
  num = line[0].to_i
  dice = line[1].to_i

  if num <= 0 || dice <= 0 || num > 10 || dice >= 2 ** 32
    event.respond(content: "無効なダイスの値です。", ephemeral: true)
    next
  end

  dices = Array.new
  for i in 1..num do
    dices.push(rand(1..dice))
  end
  sum = dices.sum
  value = "#{arg} => #{sum} (#{dices.join(', ')})"

  event.respond(content: value)
end

# chance でチャンスカードを引く
bot.message(content: 'chance') do |event|
  card = CardService.display_card
  description = card.gsub('%NAME%', event.author.display_name.to_s)
  event.respond description
end

bot.run
