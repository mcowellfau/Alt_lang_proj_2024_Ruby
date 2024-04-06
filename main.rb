require 'csv'
class Cell
    attr_accessor :oem, :model, :launchAnnounced, :launchStatus,
                  :bodyDimensions, :bodyWeight, :bodySim, :displayType,
                  :displaySize, :displayResolution, :featuresSensors, :platformOs
  
    def initialize(oem, model, launchAnnounced, launchStatus,
                   bodyDimensions, bodyWeight, bodySim, displayType,
                   displaySize, displayResolution, featuresSensors, platformOs)
      @oem = oem
      @model = model
      @launchAnnounced = launchAnnounced
      @launchStatus = launchStatus
      @bodyDimensions = bodyDimensions
      @bodyWeight = bodyWeight
      @bodySim = bodySim
      @displayType = displayType
      @displaySize = displaySize
      @displayResolution = displayResolution
      @featuresSensors = featuresSensors
      @platformOs = platformOs
    end
  end
  
  
  
  
  def clean_data(value, column_name)
    
  end
  
  csv_data = CSV.read('cells.csv', headers: true).map do |row|
    Cell.new(
      row['oem'], row['model'], row['launchAnnounced'].to_i, row['launchStatus'],
      row['bodyDimensions'], row['bodyWeight'].to_f, row['bodySim'], row['displayType'],
      row['displaySize'], row['displayResolution'], row['featuresSensors'], row['platformOs']
    )
  end
  
 
  