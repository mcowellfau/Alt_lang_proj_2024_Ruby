# Required the Ruby CSV library for parsing CSV files
require 'csv'
# Required for running unit tests
require 'minitest/autorun'
require 'ostruct'
# Defines a class named Cell to represent a cell phone with various attributes
class Cell
    # Creates getter and setter methods for each cell phone attribute using the correct naming convention
    attr_accessor :oem, :model, :launch_announced, :launch_status,
                  :body_dimensions, :body_weight, :body_sim, :display_type,
                  :display_size, :display_resolution, :features_sensors, :platform_os

    # Initializes a new instance of the Cell class
    def initialize(oem, model, launch_announced, launch_status,
                   body_dimensions, body_weight, body_sim, display_type,
                   display_size, display_resolution, features_sensors, platform_os)
      @oem = oem
      @model = model
      @launch_announced = launch_announced
      @launch_status = launch_status
      @body_dimensions = body_dimensions
      @body_weight = body_weight
      @body_sim = body_sim
      @display_type = display_type
      @display_size = display_size
      @display_resolution = display_resolution
      @features_sensors = features_sensors
      @platform_os = platform_os
    end
end

def clean_data(value, column_name)
  case column_name
  when 'oem', 'model', 'body_dimensions', 'display_type', 'display_resolution'
    # Replace nil, empty string, or "-" with nil
    if value.nil? || value.strip.empty? || value.strip == "-"
      nil
    else
      value
    end  
  when 'launch_announced'
    # Use regex to find a 4-digit number. If found, return it as an integer
    if match = value.to_s.match(/\b(\d{4})\b/)
      match[1].to_i
    else
      # Return nil if no valid year is found
      nil
    end
  when 'launch_status'
    # Keep 'Discontinued' or 'Cancelled' as is, otherwise try to find a 4-digit year
    if ['Discontinued', 'Cancelled'].include?(value)
      value
    else
      if match = value.to_s.match(/\b(\d{4})\b/)
        match[1]  # Keep as a string to maintain uniformity in data type
      else
        # Return nil if the value is neither a valid year nor one of the specified strings
        nil
      end
    end
  when 'body_weight'
    # Use regex to extract the number before 'g' and convert it to a float
    if match = value.to_s.match(/(\d+(\.\d+)?)\s*g/)
      match[1].to_f
    else
      # Return nil if no valid number is found before 'g'
      nil
    end
  when 'body_sim'
    # Replace "No" or "Yes" values with nil, consider other strings composed of letters as valid
    if value == "No" || value == "Yes"
      nil
    else
      value  # Assuming other strings are valid
    end
  when 'display_size'
    # Use regex to find an integer or a float followed by the word "inches"
    if match = value.to_s.match(/(\d+(\.\d+)?)\s*inches/)
      match[1].to_f
    else
      # Return nil if the format is not as expected
      nil
    end
  when 'features_sensors'
    # Check if the value is purely numeric
    if value.to_s.match(/\A\d+(\.\d+)?\z/)
      nil  # Return nil if the value is purely numeric
    else
      value  # Valid data includes strings of letters or numbers, including "V1"
    end
  when 'platform_os'
    # Shorten to everything up to the first comma or the entire string if there's no comma
    # Also, replace purely numeric values with nil
    if value.to_s.match(/\A\d+(\.\d+)?\z/)
      nil
    else
      shortened_value = value.to_s.split(',', 2).first
      shortened_value.nil? || shortened_value.strip.empty? ? nil : shortened_value.strip
    end
  else
    # By default, return the value as it is
    value
  end
end

# Reads data from 'cells.csv' and creates an array of Cell instances, one for each row in the CSV.
csv_data = CSV.read('cells.csv', headers: true).map do |row|
  Cell.new(
    clean_data(row['oem'], 'oem'),
    clean_data(row['model'], 'model'),
    clean_data(row['launch_announced'], 'launch_announced'), 
    clean_data(row['launch_status'], 'launch_status'),
    clean_data(row['body_dimensions'], 'body_dimensions'),
    clean_data(row['body_weight'], 'body_weight').to_f,
    clean_data(row['body_sim'], 'body_sim'),
    clean_data(row['display_type'], 'display_type'),
    clean_data(row['display_size'], 'display_size'),
    clean_data(row['display_resolution'], 'display_resolution'),
    clean_data(row['features_sensors'], 'features_sensors'),
    clean_data(row['platform_os'], 'platform_os')
  )
end
# COMMENTED OUT CLEANED .CSV FILE GENERATION CODE UNCOMMENT LINES (125-149) TO USE (file name is cleaned_cells.csv)
# New csv file name
# new_csv_file = 'cleaned_cells.csv'

# # Open a new CSV file for writing
# CSV.open(new_csv_file, 'w') do |csv|
#   # Write the header row to the new CSV
#   csv << ['oem', 'model', 'launch_announced', 'launch_status', 'body_dimensions', 'body_weight', 'body_sim', 'display_type', 'display_size', 'display_resolution', 'features_sensors', 'platform_os']

#   # Iterate over each Cell instance in csv_data and write its attributes to the new CSV
#   csv_data.each do |cell|
#     csv << [
#       cell.oem,
#       cell.model,
#       cell.launch_announced,
#       cell.launch_status,
#       cell.body_dimensions,
#       cell.body_weight,
#       cell.body_sim,
#       cell.display_type,
#       cell.display_size,
#       cell.display_resolution,
#       cell.features_sensors,
#       cell.platform_os
#     ]
#   end
# end

#FUNCTION 1 writing unique oems and models to a txt file
def write_unique_oems_and_models_to_file(csv_data, file_path)
  unique_oems = csv_data.map(&:oem).uniq.compact
  unique_models = csv_data.map(&:model).uniq.compact

  File.open(file_path, 'w') do |file|
    file.puts "Unique OEMs:"
    unique_oems.each { |oem| file.puts oem }

    file.puts "\nUnique Models:"
    unique_models.each { |model| file.puts model }
  end
end

# FUNCTION 2 writing unique features and platform os
def write_unique_features_and_platforms_to_file(csv_data, output_file_name = 'unique_features_and_platforms.txt')
  unique_features_sensors = csv_data.map(&:features_sensors).uniq.compact
  unique_platform_os = csv_data.map(&:platform_os).uniq.compact

  File.open(output_file_name, 'w') do |file|
    file.puts "Unique Feature Sensors:"
    unique_features_sensors.each { |feature| file.puts feature }

    file.puts "\nUnique Platform OS:"
    unique_platform_os.each { |os| file.puts os }
  end
  puts "Unique Feature Sensors and Platform OS values have been written to #{output_file_name}"
end

#FUNCTION 3 finding the highest avg weight
def find_highest_average_weight(csv_data)
  # Initialize a hash to hold the sum of weights and count of phones for each OEM
  weights_sum_and_count = {}

  # Iterate over each cell to aggregate weights by OEM
  csv_data.each do |cell|
    # Next line if weight is nil or not a number
    next if cell.body_weight.nil? || !cell.body_weight.is_a?(Numeric)

    # If the OEM key doesn't exist, initialize it
    weights_sum_and_count[cell.oem] ||= { sum: 0, count: 0 }
    # Aggregate the total weight and increment the count
    weights_sum_and_count[cell.oem][:sum] += cell.body_weight
    weights_sum_and_count[cell.oem][:count] += 1
  end
  # Calculate the average weight for each OEM
  average_weights = weights_sum_and_count.map do |oem, data|
    [oem, data[:sum] / data[:count].to_f]
  end.to_h
  # Find the OEM with the highest average weight
  highest_average = average_weights.max_by { |oem, avg_weight| avg_weight }

  # Return the OEM and their average weight
  highest_average
end

#FUNCTION 4  finds which oems have different announcement and release years
def phones_announced_released_different_years(csv_data)
  phones_different_years = []

  csv_data.each do |cell|
    # Directly use the launch_announced year assuming it's always numeric
    announced_year = cell.launch_announced.to_i

    # Attempt to extract a numeric year from launch_status, if present
    release_year_match = cell.launch_status.match(/\b(\d{4})\b/)
    release_year = release_year_match ? release_year_match[1].to_i : nil

    # Compare the years, checking both are valid (non-zero) numbers before comparing
    if announced_year > 0 && release_year && announced_year != release_year
      phones_different_years << { oem: cell.oem, model: cell.model, announced_year: announced_year, release_year: release_year }
    end
  end

  phones_different_years
end

# FUNCTION 5 Identifies phones with one feature sensor
def count_phones_with_one_features_sensor(csv_data)
  count = 0

  csv_data.each do |cell|
    sensors = cell.features_sensors.to_s.split(',')
    count += 1 if sensors.length == 1 && sensors[0].strip.length > 0
  end

  count
end

#FUNCTION 6 Identifies year with most phones released after 1999
def year_with_most_phones_post_1999(csv_data)
  # Initialize a hash to keep track of phone launches per year
  launches_per_year = Hash.new(0)

  csv_data.each do |cell|
    # Extract the year from launch_announced
    year_match = cell.launch_announced.to_s.match(/\b(20\d{2})\b/)
    year = year_match ? year_match[1].to_i : nil

    # Increment the count for the year if it's 2000 or later
    launches_per_year[year] += 1 if year && year > 1999
  end

  # Find the year with the maximum number of launches
  max_launches_year = launches_per_year.max_by { |year, count| count }

  # Return the year and the number of launches
  max_launches_year
end

#FUNCTION 7 Deletes a row of data from csv file
def delete_row_by_model(file_path, model_to_delete)
  # Read the existing data
  table = CSV.table(file_path)

  # Find the row(s) where the model matches the user input and delete it/them
  table.delete_if do |row|
    row[:model] == model_to_delete
  end

  # Write the modified data back to the file
  File.open(file_path, 'w') do |f|
    f.write(table.to_csv)
  end

  puts "Row(s) with model '#{model_to_delete}' have been deleted from #{file_path}"
end

#FUNCTION 8 Prints all data fields related to OEM input in a txt file
def search_by_oem(file_path, oem_to_search, output_file_path)
  matching_rows = CSV.read(file_path, headers: true).select do |row|
    row['oem'].casecmp?(oem_to_search)
  end

  File.open(output_file_path, 'w') do |file|
    if matching_rows.empty?
      file.puts "No data found for OEM: #{oem_to_search}"
    else
      file.puts "Found #{matching_rows.size} row(s) for OEM: #{oem_to_search}"
      matching_rows.each_with_index do |row, index|
        file.puts "Row #{index + 1}: #{row.to_h}"
      end
    end
  end
  puts "Search results have been written to #{output_file_path}"
end


# Display a menu and process user input
loop do
  puts "\nMenu Options:"
  puts "1. View unique OEMs and Models in a .txt out file"
  puts "2. View unique Feature Sensors and Platform OS in a .txt out file" 
  puts "3. View the oem with the highest average phone body_weight"
  puts "4. View OEMs with different announcement and release phones years"
  puts "5. View the number of phones with only one feature sensor"
  puts "6. View the year with the most phone launches (after 1999)"
  puts "7. Delete a row by model"
  puts "8. Search and display all data related to an OEM in a .txt file "
  puts "9. Exit"

  print "Enter your choice (1-9): "
  choice = gets.chomp

  case choice
  when "1"
    output_file_path = 'unique_oem_and_models.txt' 
    write_unique_oems_and_models_to_file(csv_data, output_file_path)
    puts "Unique OEMs and Models have been written to #{output_file_path}"
  when "2"
    write_unique_features_and_platforms_to_file(csv_data)
  when "3"
    highest_avg_oem, highest_avg_weight = find_highest_average_weight(csv_data)
    if highest_avg_oem && highest_avg_weight
      puts "The company (OEM) with the highest average phone body_weight is #{highest_avg_oem} with an average weight of #{highest_avg_weight.round(2)} grams."
    else
      puts "Could not determine the OEM with the highest average weight."
    end
  when "4"
    different_years_phones = phones_announced_released_different_years(csv_data)
    if different_years_phones.empty?
      puts "No phones were found that were announced in one year and released in another."
    else
      puts "Phones announced and released in different years:"
      different_years_phones.each do |phone|
        puts "OEM: #{phone[:oem]}, Model: #{phone[:model]}, Announced: #{phone[:announced_year]}, Released: #{phone[:release_year]}"
      end
    end
  when "5"
    number_of_phones_with_one_sensor = count_phones_with_one_features_sensor(csv_data)
    puts "Number of phones with only one feature sensor: #{number_of_phones_with_one_sensor}"
  when "6"
    max_year, max_launches = year_with_most_phones_post_1999(csv_data)
    if max_year && max_launches
      puts "The year with the most phone launches (after 1999) is #{max_year} with #{max_launches} launches."
    else
      puts "No data available for phone launches after 1999."
    end
  when "7"
    puts "Enter the model you want to delete:"
    model_to_delete = gets.chomp
    delete_row_by_model('test_cells.csv', model_to_delete)
  when "8"
    puts "Enter the OEM you want to search for:"
    oem_to_search = gets.chomp.strip # .strip removes any leading/trailing whitespace
    search_by_oem('cleaned_cells.csv', oem_to_search, 'search_results.txt')
    puts "Search completed. Results are in 'search_results.txt'."
  when "9"
    puts "Exiting..."
    break # Exit the loop
  else
    puts "Invalid choice, please enter 1-9."
  end
end

#UNIT TESTS Uncomment to run
# TEST 1
# Unit test to check for empty files

# class TestFileNotEmpty < Minitest::Test
#   def setup
#     @file_path = 'cells.csv' # Update this to the path of your CSV file (Emptytest.csv to see that it catches a failed test)
#   end
#   def test_file_not_empty
#     assert(File.exist?(@file_path), "File does not exist.")
#     refute(File.zero?(@file_path), "File is empty.")
#   end
# end

# TEST 2 DOES NOT WORK
# require_relative 'main' 

# class CellDataTypeTest < Minitest::Test
#   def setup
#     # Create a sample Cell instance with a variety of data types
#     @cell = Cell.new(
#       oem: "Test OEM",
#       model: "Test Model",
#       body_dimensions: "100 x 200 x 300",
#       launch_status: "Released 2020",
#       body_sim: "Yes",
#       display_type: "LCD",
#       display_resolution: "1920x1080",
#       features_sensors: "Accelerometer, Gyro, Proximity",
#       platform_os: "Android 10",
#       display_size: 6.5,  # This should be a float
#       body_weight: 200.5,  # This should be a float
#       launch_announced: 2020  # This should be an integer
#     )
#   end

#   def test_attribute_data_types
#     assert_kind_of String, @cell.oem
#     assert_kind_of String, @cell.model
#     assert_kind_of String, @cell.body_dimensions
#     assert_kind_of String, @cell.launch_status
#     assert_kind_of String, @cell.body_sim
#     assert_kind_of String, @cell.display_type
#     assert_kind_of String, @cell.display_resolution
#     assert_kind_of String, @cell.features_sensors
#     assert_kind_of String, @cell.platform_os

#     assert_kind_of Float, @cell.display_size
#     assert_kind_of Float, @cell.body_weight

#     assert_kind_of Integer, @cell.launch_announced
#   end
# end


#UNIT TEST 3
# class DataCleaner
#   # Cleans a single value, replacing "-" or empty strings with nil
#   def self.clean_value(value)
#     return nil if value.nil? || value.strip.empty? || value.strip == "-"
#     value.strip
#   end
# end

# # Example usage in main.rb
# # cleaned_data = DataCleaner.clean_value(raw_data)

# require_relative 'main.rb'  # Requires the main.rb file where DataCleaner is defined

# class TestDataCleaner < Minitest::Test
#   def test_clean_value
#     assert_nil DataCleaner.clean_value(""), "Empty strings should be replaced with nil"
#     assert_nil DataCleaner.clean_value("  "), "Whitespace strings should be replaced with nil"
#     assert_nil DataCleaner.clean_value("-"), "'-' should be replaced with nil"
#     assert_equal "Valid Data", DataCleaner.clean_value("Valid Data"), "Non-empty strings should remain unchanged"
#   end
# end

# UNIT TEST 4 WORKS
# require_relative 'main'  # Adjust the path as necessary
# class WriteUniqueOEMsAndModelsToFileTest < Minitest::Test
#   def setup
#     @csv_data = [
#       OpenStruct.new(oem: "OEM1", model: "ModelA"),
#       OpenStruct.new(oem: "OEM2", model: "ModelB"),
#       OpenStruct.new(oem: "OEM1", model: "ModelA"),  # Duplicate for testing uniqueness
#       OpenStruct.new(oem: nil, model: nil)           # nil values for testing .compact
#     ]
#     @file_path = 'temp_unique_oems_and_models.txt'
#   end

#   def test_file_creation_and_population
#     write_unique_oems_and_models_to_file(@csv_data, @file_path)

#     assert File.exist?(@file_path), 'File was not created'

#     expected_lines = [
#       "Unique OEMs:",
#       "OEM1",
#       "OEM2",
#       "",
#       "Unique Models:",
#       "ModelA",
#       "ModelB"
#     ]

#     actual_lines = File.readlines(@file_path).map(&:chomp)

#     assert_equal expected_lines, actual_lines, 'File contents did not match expected values'
#   end

#   def teardown
#     File.delete(@file_path) if File.exist?(@file_path)  # Cleans up by deleting the file after the test
#   end
# end

# UNIT TEST 5 WORKS
# require_relative 'main'  

# class WriteUniqueFeaturesAndPlatformsTest < Minitest::Test
#   def setup
#     @csv_data = [
#       OpenStruct.new(features_sensors: "Sensor1", platform_os: "OS1"),
#       OpenStruct.new(features_sensors: "Sensor2", platform_os: "OS2"),
#       OpenStruct.new(features_sensors: "Sensor1", platform_os: "OS1"),  # Duplicate
#       OpenStruct.new(features_sensors: nil, platform_os: nil)           # nil values for testing .compact
#     ]
#     @output_file_name = 'temp_unique_features_and_platforms.txt'
#   end

# def test_write_unique_features_and_platforms
#   write_unique_features_and_platforms_to_file(@csv_data, @output_file_name)

#   assert File.exist?(@output_file_name), 'File was not created'

#   expected_output = [
#     "Unique Feature Sensors:",
#     "Sensor1",
#     "Sensor2",
#     "",  # Accounts for the extra newline
#     "Unique Platform OS:",
#     "OS1",
#     "OS2"
#   ]

#   actual_output = File.readlines(@output_file_name).map(&:chomp)

#   assert_equal expected_output, actual_output, 'File contents did not match expected unique feature sensors and platform OS values'
# end
#   def teardown
#     File.delete(@output_file_name) if File.exist?(@output_file_name)  # Clean up by deleting the file after the test
#   end
# end

# UNIT TEST 6 
# require_relative 'main' 

# class FindHighestAverageWeightTest < Minitest::Test
#   def setup
#     # Creating a mock dataset
#     @csv_data = [
#       OpenStruct.new(oem: "OEM1", body_weight: 150),
#       OpenStruct.new(oem: "OEM1", body_weight: 100),
#       OpenStruct.new(oem: "OEM2", body_weight: 200),
#       OpenStruct.new(oem: "OEM2", body_weight: 300),
#       OpenStruct.new(oem: "OEM3", body_weight: 250)  # OEM3 has the highest single weight but not the highest average
#     ]
#   end

#   def test_find_highest_average_weight
#     expected_oem = "OEM2"
#     expected_avg_weight = 250.0  # Average weight for OEM2 (200 + 300) / 2

#     highest_avg_oem, highest_avg_weight = find_highest_average_weight(@csv_data)

#     assert_equal expected_oem, highest_avg_oem, "Expected OEM with the highest average weight does not match"
#     assert_equal expected_avg_weight, highest_avg_weight, "Expected average weight does not match"
#   end
# end

# UNIT TEST 7
# require_relative 'main'  

# class PhonesAnnouncedReleasedDifferentYearsTest < Minitest::Test
#   def setup
#     # Creating a mock dataset
#     @csv_data = [
#       OpenStruct.new(oem: "OEM1", model: "ModelA", launch_announced: "2019", launch_status: "Released 2020"),
#       OpenStruct.new(oem: "OEM2", model: "ModelB", launch_announced: "2020", launch_status: "Released 2020"),
#       OpenStruct.new(oem: "OEM3", model: "ModelC", launch_announced: "2018", launch_status: "Released 2019"),
#       OpenStruct.new(oem: "OEM4", model: "ModelD", launch_announced: "2021", launch_status: "Announced 2021")  # Example with no release year
#     ]
#   end

#   def test_phones_announced_released_different_years
#     result = phones_announced_released_different_years(@csv_data)

#     expected = [
#       { oem: "OEM1", model: "ModelA", announced_year: 2019, release_year: 2020 },
#       { oem: "OEM3", model: "ModelC", announced_year: 2018, release_year: 2019 }
#     ]

#     assert_equal expected, result, "Function did not correctly identify phones announced and released in different years"
#   end
# end

# UNIT TEST 8 DOES NOT WORK FULLY
# require_relative 'main'

# class YearWithMostPhonesPost1999Test < Minitest::Test
#   def setup
#     @csv_data = [
#       OpenStruct.new(launch_announced: "1999"),
#       OpenStruct.new(launch_announced: "2001 Q1"),
#       OpenStruct.new(launch_announced: "2002"),
#       OpenStruct.new(launch_announced: "2002"),
#       OpenStruct.new(launch_announced: "2003"),
#       OpenStruct.new(launch_announced: "2003"),
#       OpenStruct.new(launch_announced: "2003"),
#     ]
#   end

#   def test_year_with_most_phones_post_1999
#     result = year_with_most_phones_post_1999(@csv_data)
#     assert_equal([2003, 3], result)
#   end

#   def test_no_phones_post_1999
#     no_post_1999_phones = [
#       OpenStruct.new(launch_announced: "1998"),
#       OpenStruct.new(launch_announced: "1999")
#     ]
#     assert_nil year_with_most_phones_post_1999(no_post_1999_phones)
#   end

#   def test_handling_of_non_year_data
#     mixed_data = [
#       OpenStruct.new(launch_announced: "2000"),
#       OpenStruct.new(launch_announced: "N/A"),
#       OpenStruct.new(launch_announced: "Soon!"),
#       OpenStruct.new(launch_announced: "2000"),
#     ]
#     assert_equal([2000, 2], year_with_most_phones_post_1999(mixed_data))
#   end

#   def test_years_with_same_launch_count
#     same_count = [
#       OpenStruct.new(launch_announced: "2001"),
#       OpenStruct.new(launch_announced: "2001"),
#       OpenStruct.new(launch_announced: "2002"),
#       OpenStruct.new(launch_announced: "2002")
#     ]
#     expected_result = same_count.map(&:launch_announced).tally.max_by { |year, count| [count, year] }
#     assert_equal(expected_result, year_with_most_phones_post_1999(same_count))
#   end
# end


# UNIT TEST 9
# require_relative 'main' 

# class YearWithMostPhonesPost1999Test < Minitest::Test
#   def test_year_with_most_launches
#     csv_data = [
#       OpenStruct.new(launch_announced: "2001 Q3"),
#       OpenStruct.new(launch_announced: "2002"),
#       OpenStruct.new(launch_announced: "2002"),
#       OpenStruct.new(launch_announced: "2003"),
#     ]
#     assert_equal [2002, 2], year_with_most_phones_post_1999(csv_data)
#   end

#   def test_ignores_pre_2000_launches
#     csv_data = [
#       OpenStruct.new(launch_announced: "1998"),
#       OpenStruct.new(launch_announced: "1999"),
#       OpenStruct.new(launch_announced: "2001"),
#     ]
#     assert_equal [2001, 1], year_with_most_phones_post_1999(csv_data)
#   end

#   def test_no_post_1999_launches
#     csv_data = [
#       OpenStruct.new(launch_announced: "1990"),
#       OpenStruct.new(launch_announced: "1995"),
#     ]
#     assert_nil year_with_most_phones_post_1999(csv_data)
#   end

#   def test_handles_multiple_years_with_same_launch_count
#     csv_data = [
#       OpenStruct.new(launch_announced: "2001"),
#       OpenStruct.new(launch_announced: "2002"),
#       OpenStruct.new(launch_announced: "2001"),
#       OpenStruct.new(launch_announced: "2002"),
#     ]
  
#     result = year_with_most_phones_post_1999(csv_data)
#     assert_includes [[2001, 2], [2002, 2]], result
#   end
# end

# UNIT TEST 10
# require 'stringio'
# require_relative 'main' 

# class DeleteRowByModelTest < Minitest::Test
#   # Mock the CSV file's initial content
#   def setup
#     @initial_csv_content = <<~CSV
#       model,color,year
#       XYZ123,blue,2019
#       ABC789,red,2020
#       XYZ123,green,2018
#     CSV

#     @file_path = "temp.csv"
#     File.write(@file_path, @initial_csv_content)
#   end

#   # Confirm the file is deleted after tests run
#   def teardown
#     File.delete(@file_path) if File.exist?(@file_path)
#   end

#   def test_delete_existing_model
#     model_to_delete = "XYZ123"
#     delete_row_by_model(@file_path, model_to_delete)

#     # Read the file back and confirm the model is deleted
#     content_after_deletion = CSV.read(@file_path, headers: true)
#     refute content_after_deletion.any? { |row| row['model'] == model_to_delete }
#   end

#   def test_delete_non_existing_model
#     model_to_delete = "NONEXISTENT"
#     delete_row_by_model(@file_path, model_to_delete)

#     # Read the file back and assert no rows were deleted
#     content_after_deletion = File.read(@file_path)
#     assert_equal @initial_csv_content, content_after_deletion
#   end

#   def test_delete_all_rows_of_specific_model
#     model_to_delete = "XYZ123"
#     delete_row_by_model(@file_path, model_to_delete)

#     # Ensure the specific model rows are deleted, multiple occurrences
#     content_after_deletion = CSV.read(@file_path, headers: true)
#     refute content_after_deletion.any? { |row| row['model'] == model_to_delete }

#     # Ensure the file still contains rows of other models
#     assert content_after_deletion.any? { |row| row['model'] != model_to_delete }
#   end
# end

# UNIT TEST 11
# require 'tempfile'
# require_relative 'main'

# class SearchByOEMTest < Minitest::Test
#   def setup
#     # Create a temporary CSV file as input
#     @input_file = Tempfile.new(['input', '.csv'])
#     @input_file.write("oem,model\nSamsung,Galaxy\nApple,iPhone\nGoogle,Pixel\n")
#     @input_file.rewind

#     # Path for the output file
#     @output_file_path = Tempfile.new(['output', '.txt']).path
#   end

#   def teardown
#     # Confirm temporary files are closed and removed
#     @input_file.close!
#     File.delete(@output_file_path) if File.exist?(@output_file_path)
#   end

#   def test_search_found_oem
#     search_by_oem(@input_file.path, 'Apple', @output_file_path)
#     content = File.read(@output_file_path)
#     assert_includes content, "Found 1 row(s) for OEM: Apple"
#     assert_includes content, "iPhone"
#   end

#   def test_search_not_found_oem
#     search_by_oem(@input_file.path, 'Nokia', @output_file_path)
#     content = File.read(@output_file_path)
#     assert_includes content, "No data found for OEM: Nokia"
#   end

#   def test_case_insensitive_search
#     search_by_oem(@input_file.path, 'samsung', @output_file_path)
#     content = File.read(@output_file_path)
#     assert_includes content, "Found 1 row(s) for OEM: samsung"
#     assert_includes content, "Galaxy"
#   end
# end
