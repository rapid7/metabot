require 'helpers'

class Build
  include Cinch::Plugin

  match /latest_build/, method: :latest_build

  def initialize(*args)
    super(*args)
  end
  
  #
  # Call this method to get the latest build info - 
  # TODO - make this non-build-specific.
  #  
  def latest_build(m)

  end

end
