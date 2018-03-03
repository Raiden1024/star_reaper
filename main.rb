require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'explosion'
require_relative 'bullet'


class MainStar < Gosu::Window
  WIDTH = 800
  HEIGHT = 600

  # Constructor
  def initialize
    super WIDTH,HEIGHT
    self.caption = "Star Reaper"

    # Loading Assets (graphics, sound, musics, Fonts)
    @intro_image1 = Gosu::Image.new("assets/img/gosu-logo.png")
    @intro_image2 = Gosu::Image.new("assets/img/ruby-logo.png")
    @background_title = Gosu::Image.new("assets/img/title.png")
    @background_game = Gosu::Image.new("assets/img/space.png")
    @background_music = Gosu::Song.new("assets/sound/starfox.ogg")
    @intro_song = Gosu::Song.new("assets/sound/intro_song.ogg")
    @title_music = Gosu::Song.new("assets/sound/theme.ogg")
    @gameover_music = Gosu::Song.new("assets/sound/end.ogg")
    @boom_sample = Gosu::Sample.new("assets/sound/miss.wav")
    @laser_sample = Gosu::Sample.new("assets/sound/laser.wav")
    @title_label = Gosu::Font.new(self, "Arial", 100)
    @subtitle_label = Gosu::Font.new(self, "Arial", 60)
    @hud_label = Gosu::Font.new(self, "Arial", 40)

    # Base Instances Variables
    @state = :intro
    @playing = true
    @life = 3
    @score = 0
    @enemy_frequency = 1
    @enemy_count = 0
    @start_time = 0
    @explosions = []
    @bullets = []
  end

  # Display graphics by gameState (draw method)
  def draw
    case @state
    when :intro
      @intro_image1.draw(0, 0, 0)
    when :intro2
      @intro_image2.draw(0, 0, 0)
    when :start
      @background_title.draw(0, 0, 1)
      @title_label.draw("STAR-REAPER", 150, 200, 1.0, 1.0, 1.0)
      @subtitle_label.draw("Appuyez sur Espace/Start", 150, 350, 1.0, 1.0, 1.0)
    when :game
      @background_game.draw(0, 0, 0)
       @player.draw
       @hud_label.draw("Life: #{@life}", 700, 30, 1.0, 1.0, 1.0)
       @hud_label.draw("score: #{@score}", 50, 30, 1.0, 1.0, 1.0)
       @enemies.each do |enemy|
         enemy.draw
       end
       @explosions.each do |explosion|
         explosion.draw
       end
       @bullets.each do |bullet|
         bullet.draw
       end
    when :end
      @background_title.draw(0, 0, 0)
      @title_label.draw("GAME OVER", 150, 200, 1.0, 1.0, 1.0)
      @hud_label.draw("Score final: #{@score} !!", 250, 350, 1.0, 1.0, 1.0)
      @subtitle_label.draw("Espace/Start pour continuer", 150, 400, 1.0, 1.0, 1.0)
      @subtitle_label.draw("Echap/Select  pour Quitter", 150, 450, 1.0, 1.0, 1.0)
     end   
  end

  # Game logic (update method)
  def update
    if @playing
      case @state
      when :intro
        @intro_song.play
        if Gosu.milliseconds >= 5000
          @state = :intro2
        end
      when :intro2
        if Gosu.milliseconds >= 9000
          @state = :start
        end
      when :start
        @title_music.play(true)        
      when :game
        @background_music.play(true)
        if button_down?(Gosu::GpLeft) || button_down?(Gosu::KbLeft)
          @player.move(:left)
        end
        if button_down?(Gosu::GpRight) || button_down?(Gosu::KbRight)
          @player.move(:right)
        end
        if button_down?(Gosu::GpUp) || button_down?(Gosu::KbUp)
          @player.move(:up)
        end
        if button_down?(Gosu::GpDown) || button_down?(Gosu::KbDown)
          @player.move(:down)
        end         
        if rand(10) < @enemy_frequency
          @enemies.push Enemy.new(self)
        end
        @enemies.each do |enemy|
          enemy.move
          @bullets.each do |bullet|
            
            bullet.move
            if bullet.y < 0
              @bullets.delete(bullet)
            end
            if Gosu::distance(enemy.x, enemy.y,bullet.x, bullet.y) < 30
              @bullets.delete(bullet)
              @enemies.delete(enemy)
              @score += 20
              @boom_sample.play
              @explosions.push Explosion.new(self, enemy.x, enemy.y)
              @explosions.each do |explosion|
              @explosions.delete Explosion
              if explosion.finished
              end
              end
            end
          end
          if enemy.y > HEIGHT
            @enemies.delete(enemy)
            @score += 10
            @enemy_count += 1
          end
          if @enemy_count > 200
            @enemy_frequency = 2
          end
          if @enemy_count > 300
            @enemy_frequency = 3
          end
          if Gosu::distance(enemy.x, enemy.y, @player.x, @player.y) < 20
            @boom_sample.play
            @life -= 1
            @explosions.push Explosion.new(self, @player.x, @player.y)
            @explosions.each do |explosion|
              @explosions.delete Explosion
              if explosion.finished
              end
            end  
            @player.x = 400
            @player.y = 500
            @enemies = []
          end
          if @life == 0            
            @state = :end
          end
        end
      when :end
        @gameover_music.play(true)
      end
    end     
  end  

  # gameState ':game' initialization
  def initialize_game
    @player = Player.new(self)
    @state = :game
    @enemies = []
    @life = 3
    @enemy_count = 0
    @score = 0
    @enemy_frequency = 1
  end

  # Keyboard or GamePad Events
  def button_down(id)  
    case @state
    when :start
      initialize_game if id == Gosu::KbSpace || id == Gosu::GpButton6
      self.close if id == Gosu::KbEscape || id == Gosu::GpButton4
    when :game
      self.close if id == Gosu::KbEscape || id == Gosu::GpButton4
      if id == Gosu::KbSpace || id == Gosu::GpButton1
        @bullets.push Bullet.new(self, @player.x, @player.y, 0)
        @laser_sample.play
      end
    when :end
      self.close if id == Gosu::KbEscape || id == Gosu::GpButton4
      initialize_game if id == Gosu::KbSpace || id == Gosu::GpButton6
    end
  end
end

# Initialize & launch game
star_reaper = MainStar.new.show
