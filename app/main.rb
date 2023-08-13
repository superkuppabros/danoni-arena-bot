require 'discordrb'
require 'dotenv'
require_relative './service/resultService.rb'

Dotenv.load
_bot_token = ENV['BOT_TOKEN']
bot = Discordrb::Bot.new token: _bot_token

# カウントダウン
# /countdown 20 で発火、デフォルトは3秒
# 残り10の倍数秒と3秒以下で残り秒数を送信する
bot.message(start_with: '/countdown') do |event|
  seconds = event.message.to_s.split(' ')[1].to_i
  
  if seconds > 30
    event.respond "秒数が大きすぎます。"
    next
  end

  if seconds < 3
    seconds = 3
  end

  for i in 0..seconds do
    rest = seconds - i
    if rest % 10 == 0 || rest <= 3
      event.respond rest.to_s
    end
    sleep(1)
  end
end

bot.message(contains: '#danoni') do |event|
  result_service = ResultService.new
  obj = result_service.makeResultObj(event.message.to_s)
  author = event.author.display_name.to_s
  return_message = "Player: #{author}\n" + "Title: #{obj[:scoreName]}\n" + "Points: #{obj[:exScore]}"
  event.respond return_message
end

# /dice 1d6 でダイスを振れる
bot.message(start_with: '/dice') do |event|
  line = event.message.to_s.split(" ")[1].split("d")
  num = line[0].to_i
  dice = line[1].to_i

  next if num <= 0 || dice <= 0 || num >= 100 || dice >= 2 ** 32

  value = 0
  for i in 1..num do
    value += rand(1..dice)
  end
  event.respond value.to_s
end

bot.run
