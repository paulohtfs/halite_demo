$:.unshift(File.dirname(__FILE__) + "/hlt")

require 'game'
require 'jack_bot'

game = Game.new("Enemy")
LOG = game.logger
game.logger.info("Starting JackBot!")

while true
  game.update_map
  map = game.map
  me = map.me

  all_ships = map.ships
  allies = map.me.ships
  enemies = all_ships - allies
  planets = map.planets

  jack_bot = JackBot.new(me, map, allies, enemies, planets)

  commands = jack_bot.move
  game.send_command_queue(commands)
end
