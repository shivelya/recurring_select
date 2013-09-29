require "recurring_select/engine"
require "ice_cube"

module RecurringSelect

  def self.dirty_hash_to_rule(params)
    if params.is_a? IceCube::Rule
      params
    else
      if params.is_a?(String)
        params = JSON.parse(params)
      end

      params.symbolize_keys!
      rules_hash = filter_params(params)

      IceCube::Rule.from_hash(rules_hash)
    end
  end

  def self.is_valid_rule?(possible_rule)
    return true if possible_rule.is_a?(IceCube::Rule)
    return false if possible_rule.blank?

    if possible_rule.is_a?(String)
      begin
        JSON.parse(possible_rule)
        return true
      rescue JSON::ParserError
        return false
      end
    end

    # TODO: this should really have an extra step where it tries to perform the final parsing
    return true if possible_rule.is_a?(Hash)

    false #only a hash or a string of a hash can be valid
  end

  private

  def self.filter_params(params)
    params.reject!{|key, value| value.blank? || value=="null" }

    params[:until] = Time.parse(params[:until]) if params[:until]
    params[:count] = params[:count].to_i if params[:count]
    params[:interval] = params[:interval].to_i if params[:interval]
    params[:week_start] = params[:week_start].to_i if params[:week_start]

    params[:validations] ||= {}
    validations = params[:validations]
    validations.symbolize_keys!

    if validations[:day]
      validations[:day] = validations[:day].collect(&:to_i)
    end

    if validations[:day_of_month]
      validations[:day_of_month] = validations[:day_of_month].collect(&:to_i)
    end

    # this is soooooo ugly
    day_of_week = validations[:day_of_week]
    if day_of_week
      day_of_week ||= {}
      if day_of_week.length > 0 and not day_of_week.keys.first =~ /\d/
        day_of_week.symbolize_keys!
      else
        originals = day_of_week.dup
        day_of_week = {}
        originals.each{|key, value|
          day_of_week[key.to_i] = value
        }
      end
      day_of_week.each{|key, value|
        day_of_week[key] = value.collect(&:to_i)
      }
    end

    day_of_year = validations[:day_of_year]
    if day_of_year
      day_of_year = day_of_year.collect(&:to_i)
    end

    params
  end
end
