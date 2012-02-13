class System
  include Cinch::Plugin
  
  match /ps/, method: :ps
  match /df/, method: :df

  def initialize(*args)
    super(*args)
  end

  def ps(m)
    output_or_link m, `ps -aux`
  end  

  def df(m)
    output_or_link m, `df -h`
  end  
end
