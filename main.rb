class Cell
    attr_accessor :oem, :model, :launch_announced, :launch_status,
                  :body_dimensions, :body_weight, :body_sim, :display_type,
                  :display_size, :display_resolution, :features_sensors, :platform_os
  
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
  
  
  require 'csv'
  
  def clean_data(value, column_name)
    
  end
  
  csv_data = CSV.read('cells.csv', headers: true).map do |row|
    Cell.new(
      row['oem'], row['model'], row['launch_announced'].to_i, row['launch_status'],
      row['body_dimensions'], row['body_weight'].to_f, row['body_sim'], row['display_type'],
      row['display_size'], row['display_resolution'], row['features_sensors'], row['platform_os']
    )
  end
  
 
  