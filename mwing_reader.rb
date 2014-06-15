require 'creek'
require 'csv'
require 'pry'

class MwingReader
  def initialize input, output
    puts 'Otwieram plik'
    @input = Creek::Book.new input
    @output = output
    puts 'Wybieram arkusz'
    @sheet = @input.sheets.first
    @time_multiplier = 10 ** -6
    @base_date = DateTime.new(1899, 12, 30)

    # Params
    @start_time = DateTime.new(2008, 5, 1, 0, 0, 0)
    @end_time = DateTime.new(2008, 6, 1, 0, 0, 0)
    @target_id = '1'
    @hour_range = (0..24)

    create_csv
  end

  def create_csv
    puts 'Generuje CSV'
    CSV.open('./'+@output, 'wb') do |csv|
      @sheet.rows.each do |full_row|
        row = full_row.values
        measured_time = parse_datetime(row[3])
        break if measured_time >= @end_time or row.empty?
        if measured_time >= @start_time and @hour_range === measured_time.hour and row[1] == @target_id
          puts "Przerabiam czas #{measured_time}"
          csv << parse_row(row, measured_time)  
        end
      end
    end
  end

  def parse_row row, time
    [
      create_timestamp(time),
      time.day,
      (row[5].to_i * @time_multiplier).to_f.round(2)
    ] 
  end

  def parse_datetime date
    @base_date + date.to_f
  end

  def create_timestamp time
    case time.minute
    when 59
      (time.hour + 1) * 2 
    when 30, 29
      (time.hour * 2) + 1
    when 0
      time.hour * 2
    else
      binding.pry
    end / 2.0
  end
end

MwingReader.new(ARGV[0], ARGV[1])