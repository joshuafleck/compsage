module BetterDateHelper

  # This provides more accurate date rounding than DateHelper.time_ago_in_words
  def better_time_ago_in_words(from_time, to_time = Time.now, include_seconds = false, options = {})
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    I18n.with_options :locale => :en, :scope => :'datetime.distance_in_words' do |locale|
      case distance_in_minutes
        when 0..1
          return distance_in_minutes == 0 ?
                 locale.t(:less_than_x_minutes, :count => 1) :
                 locale.t(:x_minutes, :count => distance_in_minutes) unless include_seconds

          case distance_in_seconds
            when 0..4   then locale.t :less_than_x_seconds, :count => 5
            when 5..9   then locale.t :less_than_x_seconds, :count => 10
            when 10..19 then locale.t :less_than_x_seconds, :count => 20
            when 20..39 then locale.t :half_a_minute
            when 40..59 then locale.t :less_than_x_minutes, :count => 1
            else             locale.t :x_minutes,           :count => 1
          end

        when 2..44           then locale.t :x_minutes,      :count => distance_in_minutes
        when 45..89          then locale.t :about_x_hours,  :count => 1
        when 90..1439        then locale.t :about_x_hours,  :count => (distance_in_minutes.to_f / 60.0).round
        when 1440..2879      then locale.t :x_days,         :count => 1
        when 2880..43199     then locale.t :x_days,         :count => (distance_in_minutes.to_f / 1440.0).round
        when 43200..86399    then locale.t :about_x_months, :count => 1
        when 86400..525599   then locale.t :x_months,       :count => (distance_in_minutes.to_f / 43200.0).round
        when 525600..1051199 then locale.t :about_x_years,  :count => 1
        else                      locale.t :over_x_years,   :count => (distance_in_minutes / 525600).round
      end
    end
  end

end
