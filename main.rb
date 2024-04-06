# Requires the Ruby CSV library for parsing CSV files.
require 'csv'

# Defines a class named Cell to represent a cell phone with various attributes.
class Cell
    # Creates getter and setter methods for each cell phone attribute using the correct naming convention.
    attr_accessor :oem, :model, :launch_announced, :launch_status,
                  :body_dimensions, :body_weight, :body_sim, :display_type,
                  :display_size, :display_resolution, :feature_sensors, :platform_os

    # Initializes a new instance of the Cell class, setting the attributes with the values provided.
    def initialize(oem, model, launch_announced, launch_status,
                   body_dimensions, body_weight, body_sim, display_type,
                   display_size, display_resolution, feature_sensors, platform_os)
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
      @feature_sensors = feature_sensors
      @platform_os = platform_os
    end
end

def clean_data(value, column_name)
  case column_name
  when 'oem', 'model','launch_announced' 'launch_status', 'body_dimensions','body_weight', 'body_sim', 'display_type', 'display_size', 'display_resolution', 'feature_sensors', 'platform_os'
    # For most fields, if the value is nil or an empty string, replace it with nil.
    value.nil? || value.strip.empty? ? nil : value
  when 'launch_announced'
    # Use regex to find a 4-digit number within the string. If found, return it as an integer.
    if match = value.to_s.match(/\b(\d{4})\b/)
      match[1].to_i
    else
      # If no valid year is found, return nil.
      nil
    end
  when 'launch_status'

  when 'body_weight'
    # Attempt to convert body_weight to a float. If it fails or the value is empty, return nil.
    begin
      Float(value)
    rescue
      nil
    end
  else
    # By default, return the value as it is (You might not need this else block as all cases are covered)
    value
  end
end


# Reads data from 'cells.csv', assuming headers are present,
# and creates an array of Cell instances, one for each row in the CSV.
csv_data = CSV.read('cells.csv', headers: true).map do |row|
  Cell.new(
    clean_data(row['oem'], 'oem'),
    clean_data(row['model'], 'model'),
    clean_data(row['launch_announced'], 'launch_announced'), # Now returns integer year or nil
    clean_data(row['launch_status'], 'launch_status'),
    clean_data(row['body_dimensions'], 'body_dimensions'),
    clean_data(row['body_weight'], 'body_weight').to_f,
    clean_data(row['body_sim'], 'body_sim'),
    clean_data(row['display_type'], 'display_type'),
    clean_data(row['display_size'], 'display_size'),
    clean_data(row['display_resolution'], 'display_resolution'),
    clean_data(row['feature_sensors'], 'feature_sensors'),
    clean_data(row['platform_os'], 'platform_os')
  )
end

