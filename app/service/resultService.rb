class ResultService
  private def readResult(line)
        items = line.split('/') # 名前や曲名に/が入ると検出できなくなる
    title_reg_exp = %r{^【.*?】(.*)[/\(](.*?)k-(.*?)(?:\)\s)?/}
    header = title_reg_exp.match(line.to_s).to_a
    title = header[1]
    key_type = header[2]
    level_name = header[3]

    # MFV2's source
    if items[4].split('-').length == 5
      score = items[7].delete('Sco').split('-')[1].to_i
      note_judges = items[4].split('-').map(&:to_i)
      freeze_judges = items[5].split('-').map(&:to_i)
      combo_judges = items[6].delete('Mc').split('-').map(&:to_i)
      creator = items[2].to_s
    else
      score = items[3].split(':')[1]
      note_judges = items[5].split('-').map(&:to_i)
      freeze_judges = items[6].split('-').map(&:to_i)
      combo_judges = items[7].split('-').map(&:to_i)
      creator = items[1].to_s.split(' ')[0]
    end

    result_data = {
      'ii' => note_judges[0].to_i,
      'syakin' => note_judges[1].to_i,
      'matari' => note_judges[2].to_i,
      'shobon' => note_judges[3].to_i,
      'uwan' => note_judges[4].to_i,
      'kita' => freeze_judges[0].to_i,
      'ikunai' => freeze_judges[1].to_i,
      'maxcombo' => combo_judges[0].to_i,
      'frzcombo' => combo_judges[1].to_i,
      'score' => score.to_i
    }

    {result_data:, title:, key_type:, level_name:, creator:}
  end


  def arenaResult(line)
    parsed = readResult(line)
    result_data = parsed[:result_data]
    title = parsed[:title]
    level_name = parsed[:level_name]

    scoreName = "#{title}[#{level_name}]"
    exScore = result_data['ii'] * 3 + result_data['syakin'] * 2 + result_data['matari'] + result_data['kita'] * 3
    percentage = (exScore * 100 / ((result_data['ii'] + result_data['syakin'] + result_data['matari'] + result_data['shobon'] + result_data['uwan'] + result_data['ikunai'] + result_data['kita'] ) * 3).to_f).round(4)

    "Title: #{scoreName}\n" + "Points: #{exScore}\n" + "Percentage: #{percentage}%"
  end

  def speedTwisterResult(line)
    parsed = readResult(line)
    result_data = parsed[:result_data]
    title = parsed[:title]
    level_name = parsed[:level_name]

    scoreName = "#{title}[#{level_name}]"

    normalScore = result_data['ii'] + result_data['syakin'] + result_data['kita']
    matariScore = result_data['matari']
    missScore = result_data['shobon'] + result_data['uwan'] + result_data['ikunai']
    comboScore = result_data['maxcombo'] + result_data['frzcombo']

    total = normalScore + matariScore + missScore
    recoveryRate = (normalScore * 100 / total.to_f).round(4)
    comboRate = (comboScore * 100 / total.to_f).round(4)

    # {scoreName:, normalScore:, matariScore:, missScore:, recoveryRate:, comboRate:}
    "譜面: #{scoreName}\n" + "素点: #{normalScore} (マターリ: #{matariScore}, ミス: #{missScore})\n" + "回復率: #{recoveryRate}% (#{normalScore}/#{total}) \n" + "コンボ率: #{comboRate}% (#{comboScore}/#{total})"
  end

end
