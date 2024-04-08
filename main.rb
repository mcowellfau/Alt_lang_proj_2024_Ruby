# Requires the Ruby CSV library for parsing CSV files
require 'csv'

# Defines a class named Cell to represent a cell phone with various attributes
class Cell
    # Creates getter and setter methods for each cell phone attribute using the correct naming convention
    attr_accessor :oem, :model, :launch_announced, :launch_status,
                  :body_dimensions, :body_weight, :body_sim, :display_type,
                  :display_size, :display_resolution, :features_sensors, :platform_os

    # Initializes a new instance of the Cell class, setting the attributes with the values provided
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
    if match = value.to_s.match(/(\d+)\s*g/)
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

# Reads data from 'cells.csv', assuming headers are present,
# and creates an array of Cell instances, one for each row in the CSV.
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
#COMMENTED OUT CLEANED .CSV FILE GENERATION CODE UNCOMMENT LINES (124-148) TO USE
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


#FUNCTION 4 
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


# FUNCTION 5
def count_phones_with_one_features_sensor(csv_data)
  count = 0

  csv_data.each do |cell|
    sensors = cell.features_sensors.to_s.split(',')
    count += 1 if sensors.length == 1 && sensors[0].strip.length > 0
  end

  count
end
#MOVED COMMENTED LINES BELOW TO MENU
# number_of_phones_with_one_sensor = count_phones_with_one_features_sensor(csv_data)
# puts "Number of phones with only one feature sensor: #{number_of_phones_with_one_sensor}"

#FUNCTION 6
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

#MOVED COMMENTED LINES BELOW TO MENU
# max_year, max_launches = year_with_most_phones_post_1999(csv_data)
# if max_year && max_launches
#   puts "The year with the most phone launches (after 1999) is #{max_year} with #{max_launches} launches."
# else
#   puts "No data available for phone launches after 1999."
# end

#FUNCTION 7
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
#PUT COMMENTED LINES BELOW IN MENU
# puts "Enter the model you want to delete:"
# model_to_delete = gets.chomp
# delete_row_by_model('test_cells.csv', model_to_delete)

#FUNCTION 8
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


#Display a menu and process user input
loop do
  puts "\nMenu Options:"
  puts "1. View unique OEMs and Models in a .txt out file"
  puts "2. View unique Feature Sensors and Platform OS in a .txt out file" 
  puts "3. View the oem with the highest average weight of phone body"
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
    # Collect unique 'oem' and 'model' values
    unique_oems = csv_data.map(&:oem).uniq.compact  # .compact removes nil values
    unique_models = csv_data.map(&:model).uniq.compact

    # Open a text file for writing
    File.open('unique_oem_and_models.txt', 'w') do |file|
      file.puts "Unique OEMs:"
      unique_oems.each { |oem| file.puts oem }

      file.puts "\nUnique Models:"
      unique_models.each { |model| file.puts model }
    end
  when "2"
    # Extract unique 'features_sensors' values
    unique_features_sensors = csv_data.map(&:features_sensors).uniq.compact
    # Extract unique 'platform_os' values
    unique_platform_os = csv_data.map(&:platform_os).uniq.compact

    # Define the output file name
    output_file_name = 'unique_features_and_platforms.txt'

    # Open a text file for writing the unique values
    File.open(output_file_name, 'w') do |file|
      file.puts "Unique Feature Sensors:"
      unique_features_sensors.each { |feature| file.puts feature }

      file.puts "\nUnique Platform OS:"
      unique_platform_os.each { |os| file.puts os }
    end
    puts "Unique Feature Sensors and Platform OS values have been written to #{output_file_name}"
  when "3"
    highest_avg_oem, highest_avg_weight = find_highest_average_weight(csv_data)
    if highest_avg_oem && highest_avg_weight
      puts "The company (OEM) with the highest average weight of phone body is #{highest_avg_oem} with an average weight of #{highest_avg_weight.round(2)} grams."
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
    # Prompt the user for OEM to search for and directly use it in the function call
    puts "Enter the OEM you want to search for:"
    oem_to_search = gets.chomp.strip # .strip removes any leading/trailing whitespace
    # Directly calling the function with the necessary parameters
    search_by_oem('cleaned_cells.csv', oem_to_search, 'search_results.txt')
    puts "Search completed. Results are in 'search_results.txt'."
  when "9"
    puts "Exiting..."
    break # Exit the loop
  else
    puts "Invalid choice, please enter 1-9."
  end
end




