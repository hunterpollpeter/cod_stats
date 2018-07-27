class Player < ApplicationRecord
  def self.api_find(platform, gamer_tag, title)
    player = Player.find_by(username: gamer_tag, platform: platform, title: title)
    return player if player
    resp = JSON.parse(HTTP.get(api_url(platform, gamer_tag, title)))
    return nil unless resp['status'] == 'success'
    player = Player.find_or_initialize_by(username: gamer_tag, platform: platform, title: title)
    player.data = resp['data']
    player.save
    player
  end

  def self.api_get(id)
    player = Player.find_by(id: id)
    return nil unless player
    return player unless player.needs_update?
    resp = JSON.parse(HTTP.get(api_url(player.platform, player.username, player.title)))
    return nil unless resp['status'] == 'success'
    player.data = resp['data']
    player.map_weapon_data
    player.save
    player
  end

  def needs_update?
    Time.now >= (updated_at + 30.minutes)
  end

  def level
    mp_data['level'].to_i
  end

  def prestige
    mp_data['prestige'].to_i
  end

  def kd_ratio(mode = nil, weekly = false)
    return get_mode_data('kdRatio', nil, weekly) unless mode
    ks = kills mode, weekly
    ds = deaths mode, weekly
    return nil unless ks && ds
    kd = ks.to_f / ds.to_f
    kd&.nan? ? nil : kd
  end

  def kills(mode = nil, weekly = false)
    get_mode_data('kills', mode, weekly).to_i
  end

  def deaths(mode = nil, weekly = false)
    get_mode_data('deaths', mode, weekly).to_i
  end

  def win_percentage(mode = nil, weekly = false)
    ws = wins mode, weekly
    ls = losses mode, weekly
    return nil unless ws && ls
    return 1 if ws.nonzero? && ls.zero?
    return nil if ls.zero?
    ws.to_f / (ws + ls).to_f
  end

  def wins(mode = nil, weekly = false)
    get_mode_data('wins', mode, weekly).to_i
  end

  def losses(mode = nil, weekly = false)
    get_mode_data('losses', mode, weekly).to_i
  end

  def best_weapon(weekly = false)
    data = get_data 'allNonNumerical', weekly
    return nil unless data
    data['bestWeapon']['label']
  end

  def best_primary(weekly = false)
    data = get_data 'allNonNumerical', weekly
    return nil unless data
    data['bestPrimary']['label']
  end

  def best_secondary(weekly = false)
    data = get_data 'allNonNumerical', weekly
    return nil unless data
    data['best_secondary']['label']
  end

  def best_score_streak(weekly = false)
    data = get_data 'allNonNumerical', weekly
    return nil unless data
    data['bestScorestreakAttack']['label']
  end

  def mode_score(mode = nil, weekly = false)
    kd = kd_ratio mode, weekly
    win_pct = win_percentage mode, weekly
    spm = score_per_minute mode, weekly
    return nil unless kd && win_pct && spm
    ((kd + (win_pct / 10) + (spm / 1000)) * 1000).to_i
  end

  def score(mode = nil, weekly = false)
    get_mode_data 'score', mode, weekly
  end

  def time_played(mode = nil, weekly = false)
    stat = mode.to_s.start_with?('division:') ? 'timeInUse' : 'timePlayed'
    get_mode_data stat, mode, weekly
  end

  def score_per_minute(mode = nil, weekly = false)
    scr = score mode, weekly
    tp = time_played mode, weekly
    return nil unless scr && tp
    spm = scr / (tp / 60)
    spm.nan? ? nil : spm
  end

  def kills_per_minute(mode = nil, weekly = false)
    ks = kills mode, weekly
    tp = time_played mode, weekly
    return nil unless ks && tp
    kpm = ks / (tp / 60)
    kpm.nan? ? nil : kpm
  end

  def deaths_per_minute(mode = nil, weekly = false)
    ds = deaths mode, weekly
    tp = time_played mode, weekly
    return nil unless ds && tp
    dpm = ds / (tp / 60)
    dpm.nan? ? nil : dpm
  end

  def self.modes
    { dm:       'Free For All',
      hp:       'Hardpoint',
      sd:       'Search & Destroy',
      ctf:      'Capture the Flag',
      dom:      'Domination',
      gun:      'Gun Game',
      war:      'Team Deathmatch',
      ball:     'Gridiron',
      conf:     'Kill Confirmed',
      demo:     'Demolition',
      dm_hc:    'Hardcore Free For All',
      sd_hc:    'Hardcore Search & Destroy',
      dom_hc:   'Hardcore Domination',
      war_hc:   'Hardcore Team Deathmatch',
      conf_hc:  'Hardcore Kill Confirmed' }
  end

  def self.divisions
    { 'division:armored': 'Armored',
      'division:airborne': 'Airborne',
      'division:infantry': 'Infantry',
      'division:mountain': 'Mountain',
      'division:resistance': 'Resistance',
      'division:expeditionary': 'Expeditionary' }
  end

  def weapon(weapon_name)
    weapon_data[weapon_name]
  end

  def weapon_data
    get_data('weaponData', false)
  end

  def map_weapon_data
    weapon_data&.each do |weapon_name, _|
      weapon_type, weapon_class = Player.weapon_map weapon_name
      weapon_data[weapon_name]['weapon_type'] = weapon_type
      weapon_data[weapon_name]['weapon_class'] = weapon_class
    end
  end

  def weapon_type_data(weapon_type)
    weapons = weapon_data.select { |_, data|
      data['weapon_type'] == weapon_type.to_s
    }
    kills = 0
    deaths = 0
    multikills = 0
    time_in_use = 0
    time_in_use = 0
    shots = 0
    hits = 0
    weapons.each do |_, weapon_data|
      kills += weapon_data['kills']
      deaths += weapon_data['deaths']
      multikills += weapon_data['multikills']
      time_in_use += weapon_data['timeInUse']
      hits += weapon_data['hits']
      shots += weapon_data['shots']
    end
    {
      kills: kills,
      deaths: deaths,
      multikills: multikills,
      time_in_use: time_in_use,
      hits: hits,
      shots: shots
    }
  end

  def accuracy
    get_mode_data('accuracy', nil, false)
  end

  def last_played
    last_game = 0
    Player.modes.each do |mode, _|
      mode_last_game = get_mode_data 'timeStampLastGame', mode, false
      last_game = mode_last_game if last_game < mode_last_game
    end
    last_game
  end

  private

  def mp_data
    data['mp']
  end

  def lifetime_mp_data
    mp_data['lifetime']
  end

  def weekly_mp_data
    mp_data['weekly']
  end

  def get_mode_data(stat, mode, weekly)
    data = get_data('all', weekly)
    return nil if data.none?
    return data[stat] unless mode
    data = get_data('mode', weekly)
    return nil unless data
    data_mode = data[mode.to_s]
    data_mode[stat] if data_mode
  end

  def get_data(data_name, weekly)
    data = weekly ? weekly_mp_data : lifetime_mp_data
    return nil unless data
    data[data_name]
  end

  def self.api_url(platform, gamer_tag, title)
    "https://my.callofduty.com/api/papi-client/crm/cod/v2/title/#{title}/platform/#{platform}/gamer/#{gamer_tag}/profile/"
  end

  def self.weapon_map(weapon)
    data = Player.weapons[:"#{weapon}"]
    [data[:type], data[:class]] if data
  end

  def self.weapons
    {
      'BAR': { type: 'rifle', class: 'primary' },
      '1191': { type: 'pistol', class: 'secondary ' },
      'Bren': { type: 'light_machine_gun', class: 'primary' },
      'GPMG': { type: 'light_machine_gun', class: 'primary' },
      'M-38': { type: 'submachine_gun', class: 'primary' },
      'Orso': { type: 'submachine_gun', class: 'primary' },
      'P-08': { type: 'pistol', class: 'secondary' },
      'Sten': { type: 'submachine_gun', class: 'primary' },
      'FG 42': { type: 'rifle', class: 'primary' },
      'Lewis': { type: 'light_machine_gun', class: 'primary' },
      'M1903': { type: 'sniper_rifle', class: 'primary' },
      'M1928': { type: 'submachine_gun', class: 'primary' },
      'M1941': { type: 'rifle', class: 'primary' },
      'MG 15': { type: 'light_machine_gun', class: 'primary' },
      'MG 42': { type: 'light_machine_gun', class: 'primary' },
      'MG 81': { type: 'light_machine_gun', class: 'primary' },
      'MP-40': { type: 'submachine_gun', class: 'primary' },
      'STG44': { type: 'rifle', class: 'primary' },
      'Kar98k': { type: 'sniper_rifle', class: 'primary' },
      'SVT-40': { type: 'rifle', class: 'primary' },
      'Type 5': { type: 'rifle', class: 'primary' },
      'ZK-383': { type: 'submachine_gun', class: 'primary' },
      '9mm SAP': { type: 'pistol', class: 'secondary' },
      'Karabin': { type: 'sniper_rifle', class: 'primary' },
      'PPSh-41': { type: 'submachine_gun', class: 'primary' },
      'PTRS-41': { type: 'sniper_rifle', class: 'primary' },
      'Stinger': { type: 'light_machine_gun', class: 'primary' },
      'Type 38': { type: 'sniper_rifle', class: 'primary' },
      'Claymore': { type: 'melee', class: 'secondary' },
      'Fire Axe': { type: 'melee', class: 'secondary' },
      'Ice Pick': { type: 'melee', class: 'secondary' },
      'Sterling': { type: 'submachine_gun', class: 'primary' },
      'Type 100': { type: 'submachine_gun', class: 'primary' },
      'Waffe 28': { type: 'submachine_gun', class: 'primary' },
      'Gewehr 43': { type: 'rifle', class: 'primary' },
      'M1 Garand': { type: 'rifle', class: 'primary' },
      'US Shovel': { type: 'melee', class: 'secondary' },
      'Grease Gun': { type: 'submachine_gun', class: 'primary' },
      'ITRA Burst': { type: 'rifle', class: 'primary' },
      'M1 Bazooka': { type: 'launcher', class: 'secondary' },
      'M2 Carbine': { type: 'rifle', class: 'primary' },
      'Blunderbuss': { type: 'shotgun', class: 'primary' },
      'Lee Enfield': { type: 'rifle', class: 'primary' },
      'Baseball bat': { type: 'melee', class: 'secondary' },
      'Combat knife': { type: 'melee', class: 'secondary' },
      'Lever Action': { type: 'sniper_rifle', class: 'primary' },
      'M1A1 Carbine': { type: 'rifle', class: 'primary' },
      'Nambu Type 2': { type: 'submachine_gun', class: 'primary' },
      'Trench Knife': { type: 'melee', class: 'secondary' },
      'Enfield No. 2': { type: 'pistol', class: 'secondary' },
      'Panzerschreck': { type: 'launcher', class: 'secondary' },
      'Toggle Action': { type: 'shotgun', class: 'primary' },
      'Combat Shotgun': { type: 'shotgun', class: 'primary' },
      'Machine Pistol': { type: 'pistol', class: 'secondary' },
      'Reichsrevolver': { type: 'pistol', class: 'secondary' },
      'Volkssturmgewehr': { type: 'rifle', class: 'primary' },
      'Sawed-off Shotgun': { type: 'shotgun', class: 'primary' },
      'M30 Luftwaffe Drilling': { type: 'shotgun', class: 'primary' }
    }
  end
end
