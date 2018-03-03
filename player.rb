class Player
  attr_accessor :x, :y, :velocity_x, :velocity_y

  def initialize(game)
    @x = x = 400
    @y = y = 500
    @sprite = Gosu::Image.new('assets/img/ship.png')
    @velocity_x = 10
    @velocity_y = 10
    @game = game
  end

  def move(direction)
    case direction
    when :left
      @x -= @velocity_x
      if @x < 0
        @x = 0
      end
    when :right
      @x += @velocity_x
      if @x > 750
        @x = 750
      end
    when :up
      @y -= @velocity_y
      if @y < 0
        @y = 0
      end
    when :down
      @y += @velocity_y
      if @y > 550
        @y = 550
      end
   end
  end

  def draw
    @sprite.draw(@x, @y, 1)
  end
  
end
