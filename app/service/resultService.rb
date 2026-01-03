class ResultService
  # return {scoreName, exScore}
  def makeResultObj(line)
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

    scoreName = "#{title}[#{level_name}]"
    exScore = result_data['ii'] * 3 + result_data['syakin'] * 2 + result_data['matari'] + result_data['kita'] * 3
    percentage = exScore * 100 / ((result_data['ii'] + result_data['syakin'] + result_data['matari'] + result_data['shobon'] + result_data['uwan'] + result_data['ikunai'] + result_data['kita'] ) * 3).to_f

    {exScore:, scoreName:, percentage:}
  end
end
