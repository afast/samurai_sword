class Card
  TYPE = [:weapon, :property, :action]
  WEAPONS = [
    :bo, :bo, :bo, :bo, :bo, :bokken, :bokken, :bokken, :bokken, :bokken, :bokken,
    :daikyu, :kanabo, :katana, :kiseru,  :kiseru, :kiseru, :kiseru, :kiseru, :kusarigama, :kusarigama, :kusarigama, :kusarigama,
    :nagayari, :naginata, :naginata, :nodachi, :shuriken, :shuriken, :shuriken, :tanegashima, :wakizashi
  ]

  CARDS = {
    bo: {
      type: :weapon,
      distance: 2,
      damage: 1,
      count: 5
    },
    bokken: {
      type: :weapon,
      distance: 1,
      damage: 1,
      count: 6
    },
    daikyu: {
      type: :weapon,
      distance: 5,
      damage: 2,
      count: 1
    },
    kanabo: {
      type: :weapon,
      distance: 3,
      damage: 2,
      count: 1
    },
    katana: {
      name: :katana,
      type: :weapon,
      distance: 2,
      damage: 3,
      count: 1
    },
    kiseru: {
      type: :weapon,
      distance: 1,
      damage: 2,
      count: 5
    },
    kusarigama: {
      type: :weapon,
      distance: 2,
      damage: 2,
      count: 4
    },
    nagayari: {
      type: :weapon,
      distance: 4,
      damage: 2,
      count: 1
    },
    naginata: {
      type: :weapon,
      distance: 4,
      damage: 1,
      count: 2
    },
    nodachi: {
      type: :weapon,
      distance: 3,
      damage: 3,
      count: 1
    },
    shuriken: {
      type: :weapon,
      distance: 3,
      damage: 1,
      count: 3
    },
    tanegashima: {
      type: :weapon,
      distance: 5,
      damage: 1,
      count: 1
    },
    wakizashi: {
      type: :weapon,
      distance: 1,
      damage: 3,
      count: 1
    }
  }

  attr_accessor :type, :name, :distance, :damage

  def self.initialize_weapons
    WEAPONS.map do |w|
      Card.new(w, CARDS[w])
    end
  end

  def initialize(name, attrs)
    @name = name
    @type = attrs[:type]
    @distance = attrs[:distance]
    @damage = attrs[:damage]
  end
end
