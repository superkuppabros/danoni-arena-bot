require 'csv'

class CardService
  def self.display_card
    cards = load_cards

    # Calculate cumulative probabilities
    cumulative_rate = 0
    cards.each { |card| card[:cumulative_rate] = cumulative_rate += card[:rate] }

    # Generate a random number between 0 and 100
    random_value = rand(100)

    # Select the card based on the random value
    selected_card = cards.find { |card| random_value < card[:cumulative_rate] }

    if selected_card
      puts "Name: #{selected_card[:name]}"
      puts "Description: #{selected_card[:description]}"
    else
      puts 'No card selected.'
    end

    selected_card[:description]
  end

  private

  def self.load_cards
    file_path = File.join(__dir__, '../resources/card_list.tsv')
    cards = []

    CSV.foreach(file_path, col_sep: "\t", headers: true, header_converters: :symbol) do |row|
      cards << {
        id: row[:id].to_i,
        name: row[:name],
        rate: row[:rate].to_i,
        description: row[:description]
      }
    end

    # Ensure the total rate is 100
    total_rate = cards.sum { |card| card[:rate] }
    raise "Total rate must be 100, but it is #{total_rate}" unless total_rate == 100

    cards
  end
end