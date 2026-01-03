require 'discordrb'
require 'dotenv'
require_relative './service/resultService.rb'
require_relative './service/cardService.rb'

Dotenv.load
_bot_token = ENV["BOT_TOKEN"]
bot = Discordrb::Bot.new(token: _bot_token)
# bot = Discordrb::Commands::CommandBot.new(token: _bot_token, prefix: '!')

# スラッシュコマンド登録時のデバッグログを追加
puts "[DEBUG] スラッシュコマンドを登録中..."

bot.register_application_command(:countdown, "カウントダウンを開始します") do |cmd|
  cmd.integer(:seconds, "カウントダウンする秒数", required: false)
end

bot.register_application_command(:dice, "ダイスを振ります") do |cmd|
  cmd.string(:roll, "振るダイスの形式 (例: 2d6)", required: false)
end

puts "[DEBUG] スラッシュコマンドの登録が完了しました。"

# event.optionsのキーをStringとして明示的に扱う
bot.application_command(:countdown) do |event|
  puts "[DEBUG] /countdown コマンドが呼び出されました。"
  puts "[DEBUG] event.options: #{event.options.inspect}"

  seconds = event.options["seconds"] || 3 # Stringキーを使用

  if seconds > 30
    event.respond(content: "秒数が大きすぎます。", ephemeral: true)
    next
  end

  if seconds < 3
    seconds = 3
  end

  for i in 0..seconds do
    rest = seconds - i
    if rest % 10 == 0 || rest <= 3
      event.respond(content: rest.to_s)
    end
    sleep(1)
  end
end

bot.message(contains: '#danoni') do |event|
  result_service = ResultService.new
  obj = result_service.makeResultObj(event.message.to_s)
  author = event.author.display_name.to_s
  return_message = "Player: #{author}\n" + "Title: #{obj[:scoreName]}\n" + "Points: #{obj[:exScore]}\n" + "Percentage: #{obj[:percentage]}%"
  event.respond return_message
end

# /dice 1d6 でダイスを振れる
bot.application_command(:dice) do |event|
  puts "[DEBUG] /dice コマンドが呼び出されました。"
  puts "[DEBUG] event.options: #{event.options.inspect}"

  arg = event.options["roll"] || "1d6"
  line = arg.split("d")
  num = line[0].to_i
  dice = line[1].to_i

  if num <= 0 || dice <= 0 || num >= 10 || dice >= 2 ** 32
    event.respond(content: "無効なダイスの値です。", ephemeral: true)
    next
  end

  dices = Array.new
  for i in 1..num do
    dices.push(rand(1..dice))
  end
  sum = dices.sum
  value = "#{sum} (#{dices.join(', ')})"

  event.respond(content: value)
end

# chance でチャンスカードを引く
bot.message(content: 'chance') do |event|
  card = CardService.display_card
  description = card.gsub('%NAME%', event.author.display_name.to_s)
  event.respond description
end

# Replace `bot.message(content: '!help')` with `bot.command :help` to avoid conflicts
# bot.command :help do |event|
#   help_message = <<~HELP
#     **利用可能なコマンド:**
#     `/countdown [秒数]` - カウントダウンタイマーを開始します（デフォルト: 3秒、最大: 30秒）。
#     `/dice [x]d[y]` - x個のy面ダイスを振ります。(例: /dice 2d6)
#     `chance` - チャンスカードを引きます。
#     `!help` - このヘルプメッセージを表示します。
#   HELP

#   event.respond help_message
# end

bot.run
