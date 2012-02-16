class Autovoice
  include Cinch::Plugin
  listen_to :join
  match /autovoice (on|off)$/

  def listen(m)
    unless m.user.nick == bot.nick
      m.channel.voice(m.user) if @autovoice
    end
  end

  def execute(m, option)
    @autovoice = option == "on"

    m.reply "Autovoice is now #{@autovoice ? 'enabled' : 'disabled'}"
  end
end
