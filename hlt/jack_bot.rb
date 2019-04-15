class JackBot
  def initialize(me, map, allies, enemies, planets)
    @me = me
    @map = map
    @allies = allies
    @enemies = enemies
    @planets = planets

    @enemy_planets = enemy_planets
    @allie_planets = allie_planets
  end

  def move
    if all_planets_docked?
      start_battle
    else
      start_conquer
    end
  end

  def start_battle
    LOG.info('Battle')
    command_queue = []

    battle_ships.each do |allie|
      command_queue << attack_enemies_ships(allie)
    end

    command_queue
  end

  def start_conquer
    command_queue = []

    @allies.each do |allie|
      if docked?(allie)
        command_queue << allie.undock if allie.planet&.full?
        command_queue << conquer_planets(allie)
      else
        command_queue << conquer_planets(allie)
      end
    end

    command_queue
  end

  def attack_enemies_ships(allie)
    target = nearst_enemies_ships_from(allie).first
    speed = Game::Constants::MAX_SPEED
    command = allie.navigate(target, @map, speed)
    command if command
  end

  def attack_enemies_planets(allie)
    target = nearst_planets_enemies_from(allie).first
    speed = Game::Constants::MAX_SPEED
    command = allie.navigate(target, @map, speed)
    command if command
  end

  def conquer_planets(allie)
    command_queue = []
    target_planets = []

    undocked_planets(allie).each do |planet|
      next if target_planets.include?(planet)

      if allie.can_dock?(planet)
        command_queue << allie.dock(planet)
      else
        speed = Game::Constants::MAX_SPEED/2
        command = allie.navigate(planet, @map, speed)
        command_queue << command if command
      end

      target_planets << planet
      break
    end

    command_queue
  end

  private

    def all_planets_docked?
      owneds = @planets.select(&:owned?)
      owneds.count == @planets.count
    end

    def nearst_planets_from(allie)
      closests = {}

      @planets.each do |planet|
        distance = allie.calculate_distance_between(planet)
        closests[distance] = planet
      end

      closests.sort_by(&:distance).map(&:planet)
    end

    def nearst_planets_enemies_from(allie)
      closests = {}

      @enemy_planets.each do |planet|
        distance = allie.calculate_distance_between(planet)
        closests[distance] = planet
      end

      closests.sort_by(&:distance).map(&:planet)
    end

    def nearst_enemies_ships_from(allie)
      closests = {}

      @enemies.each do |enemy|
        distance = allie.calculate_distance_between(enemy)
        closests[distance] = enemy
      end

      closests.sort_by(&:distance).map(&:planet)
    end

    def battle_ships
      @allies.map do |allie|
        allie unless docked?(allie)
      end.compact
    end

    def undocked_planets(allie)
      nearst_planets_from(allie).reject(&:owned?)
    end

    def docked_planets
      @planets.select(&:owned?)
    end

    # Ship Method
    def docked?(allie)
      allie.docking_status == Ship::DockingStatus::DOCKED
    end

    def planets_from(allie)
      @planets.map do |planet|
        allie.calculate_distance_between(planet)
      end.sort
    end

    def enemy_planets
      @planets.select do |planet|
        planet.owner != @me
      end
    end

    def allie_planets
      @planets.select do |planet|
        planet.owner == @me
      end
    end

    def my_planet?(planet)
      planet.owner == @me
    end
    
    def enemy_planet?(planet)
      planet.owner != @me
    end
end

class Array
  def distance
    self[0]
  end

  def planet
    self[1]
  end
end
