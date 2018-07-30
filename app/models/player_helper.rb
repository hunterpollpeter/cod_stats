module PlayerHelper
  def stat_class(stat, low, high = nil)
    return 'default' unless stat
    high ||= low
    stat = stat.to_f
    if stat == high
      'info'
    elsif stat <= low
      'danger'
    elsif stat >= high
      'success'
    else
      'warning'
    end
  end

  def stat_direction(stat, lifetime_stat)
    return nil unless stat && lifetime_stat
    return nil if stat == lifetime_stat
    return 'stat-up' if stat > lifetime_stat
    return 'stat-down' if stat < lifetime_stat
  end

  def percentage(stat)
    stat.to_f * 100 if stat
  end

  def weapon_accuracy(hits, shots)
    return nil if shots.zero?
    (hits / (hits + shots.to_f)) * 100
  end

  def stat_per_minute(stat, time_in_seconds)
    stat / (time_in_seconds / 60.0) unless time_in_seconds.zero?
  end

  def weapon_kd_ratio(kills, deaths)
    return kills if deaths.zero?
    kills / deaths.to_f
  end

  def level_image(player)
    level = player.level
    prestige = player.prestige
    return prestige_img_url prestige.to_i if prestige.nonzero?
    case level
    when 1...40   then level = (level / 3.to_f).ceil
    when 40...50  then level = (((((level - 40) + 1.01) / 3) + level) / 3).ceil
    when 50..55   then level -= 31
    end
    level_img_url level.to_i
  end

  def friendly_platform(platform)
    case platform
    when 'psn' then 'PlayStation'
    when 'xbl' then 'Xbox'
    when 'steam' then 'Steam'
    end
  end

  private

  def prestige_img_url(prestige)
    "https://my.callofduty.com/content/dam/atvi/callofduty/mycod/common/player-icons/wwii/prestige-#{prestige}.png"
  end

  def level_img_url(level)
    "https://my.callofduty.com/content/dam/atvi/callofduty/mycod/common/player-icons/wwii/level-#{level}.png"
  end
end