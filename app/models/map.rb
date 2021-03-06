require 'open-uri'
require 'net/http'

# This class represents data about a historic map.
#
# Maps don't belong to any user. A map can have annotations and control points.

class Map < ActiveRecord::Base
  
  has_many :annotations
  has_many :control_points
  
  before_validation :extract_dimensions
  validates_presence_of :identifier, :title, :width, :height
  
  # TODO: this should be in a central APP configuration file
  def map_base_uri
    "http://samos.mminf.univie.ac.at/maps"
  end
  
  def raw_image_uri
    "#{map_base_uri}/raw/#{self.identifier}.jp2"    
  end
  
  def tileset_uri
    "#{map_base_uri}/ts_zoomify/#{self.identifier}"
  end
  
  def thumbnail_uri
    "#{map_base_uri}/thumbnails/#{self.identifier}.jpg"
  end
  
  def thumbnail_small_uri
    "#{self.tileset_uri}/TileGroup0/0-0-0.jpg"
  end
  
  def overlay_tileset_uri
    uri = "#{map_base_uri}/ts_google/#{self.identifier}/"
    response_code = Net::HTTP.get_response(URI.parse(uri)).code
    return (response_code == "200") ? uri : nil
  end
  
  def short_title
    "#{self.title[0..30]}..."
  end
  
  def no_control_points
    self.control_points.count
  end
  
  # Extracts image dimensions from ImageProperties.xml;
  def extract_dimensions
    tileset_uri.chomp!('/') # remove trailing slash just in case
    url = URI.parse "#{tileset_uri}/ImageProperties.xml"
    response = Net::HTTP.get_response(url)
    if response.code == "200"
      self.width = response.body.match(/width="(\d*)"/i).captures.first
      self.height = response.body.match(/height="(\d*)"/i).captures.first
    end
    
  end
    
end
