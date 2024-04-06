# Requires the Ruby CSV library for parsing CSV files.
require 'csv'
# Defines a class named Cell to represent a cell phone with various attributes.
class Cell
    # Creates getter and setter methods for each cell phone attribute.
    attr_accessor :oem, :model, :launchAnnounced, :launchStatus,
                  :bodyDimensions, :bodyWeight, :bodySim, :displayType,
                  :displaySize, :displayResolution, :featuresSensors, :platformOs
    # Initializes a new instance of the Cell class, setting the attributes with the values provided.
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
  # Reads data from 'cells.csv', assuming headers are present,
  # and creates an array of Cell instances, one for each row in the CSV.
  csv_data = CSV.read('cells.csv', headers: true).map do |row|
    Cell.new(
      row['oem'], row['model'], row['launchAnnounced'].to_i, row['launchStatus'],
      row['bodyDimensions'], row['bodyWeight'].to_f, row['bodySim'], row['displayType'],
      row['displaySize'], row['displayResolution'], row['featuresSensors'], row['platformOs']
    )
  end
  
 
  