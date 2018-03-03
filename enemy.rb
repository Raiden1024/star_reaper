class Enemy
  SPEED = 5
  attr_reader :y, :x
  
  def initialize(game)
    @game = game
    @enemy_img = Gosu::Image.new("assets/img/meteor.png")
    @x = x = rand(800)
    @y = y = -50
  end

  def move
    @y += SPEED
  end

  def draw
    @enemy_img.draw(@x, @y, 2)
  end
  
end
