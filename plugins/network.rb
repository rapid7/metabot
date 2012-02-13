class Network
  include Cinch::Plugin

  match /[a|A][v|V] [e|E]vasion/, method: :evasion
  
  
  def initialize(*args)
    super(*args)
  end
  
  def evasion(m)  
    m.reply "AV Evasion - see: http://schierlm.users.sourceforge.net/avevasion.html && http://www.scriptjunkie.us/2011/04/why-encoding-does-not-matter-and-how-metasploit-generates-exes/"
  end
end
