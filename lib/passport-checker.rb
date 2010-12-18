# -*- encoding : utf-8 -*-
require 'date'
require 'active_support/duration'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/numeric/time'

class PassportChecker

  # Extract id_number for validity
  # if birthdate is given (as Date), check if it matches the encoded birth date
  def self.valid?(id_number, birthdate = nil)
    # rough check for format
    return false unless /[A-Z0-9<]{9}\d.{3}\d{7}[MF<]\d{7}<{15}\d/i =~ id_number

    begin
      id_birthdate = parse_date(id_number, 13, false) # assume year of birth is in the 1900 range
      id_expirydate = parse_date(id_number, 21, true) # assume year of expiry is in the 2000 range
    rescue
      return false
    end

    return false unless legal_age?(id_birthdate)
    return false unless id_expirydate > Date.today

    unless (birthdate.nil?)
      return false unless birthdate == id_birthdate
    end

    # check if inner checksums match
    [0..8, 13..18, 21..26].each do |range|
      return false unless valid_checksum?(id_number[range], id_number[range.end + 1..range.end + 1].to_i)
    end

    return false unless valid_checksum?(total_checksum_digest(id_number), id_number[-1].to_i)
    return true
  end

  def self.valid_checksum?(number_string, checksum)
    return calculate_checksum(number_string) == checksum
  end

  def self.total_checksum_digest(id_number)
    [0..9, 13..19, 21..27].inject('') { |digest, range| digest += id_number[range] }
  end

  def self.calculate_checksum(number_string)
    computed_checksum = 0
    multiplier = [7, 3, 1]
    chars = ("A".."Z").to_a
    number_string.length.times do |i|
      c = number_string[i..i]
      if chars.index(c)
        c = chars.index(c) + 10
      end
      computed_checksum += multiplier[i % 3] * c.to_i
    end
    return computed_checksum % 10
  end

  def self.legal_age?(birthdate)
    (Date.today - birthdate) > 18.years / 24 / 60 / 60
  end

  def self.parse_date(id_number, i, add2k)
    year = id_number[i..(i+1)].to_i
    if(add2k)
      year += 2000
    else
      year += 1900
    end
    Date.civil(year, id_number[(i+2)..(i+3)].to_i, id_number[(i+4)..(i+5)].to_i)
  end

end
