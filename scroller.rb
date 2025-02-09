#
#    SCROLLER    SCROLLER    SCROLLER    SCROLLER
#
#         Main Game Logic for Overlord
#

require_relative 'worldmap'
# require_relative 'bindings'

class Scroller < Widget
    def initialize
        super(0, 0, GAME_WIDTH, GAME_HEIGHT)
        set_layout(LAYOUT_HEADER_CONTENT)
        set_theme(OverTheme.new)
#        disable_border
        enable_border
        enable_background
        @pause = false
        @game_mode = RDIA_MODE_START
        @score = 0
        @level = 1
        @camera_x = 0
        @camera_y = 0

        pause_game
        add_overlay(WelcomeScreen.new(
                        "Overlord Castle", 
                        "intro"))


        # TODO put this back when we are ready 
        # to release, instructions to the user
        # add_overlay(create_overlay_widget)

        # initialize

        @grid = GridDisplay.new(0, 0, 16, 80, 38, {ARG_SCALE => 2})
        @worldmap = WorldMap.new(@grid)

        load_panels

        @worldmap.load_tiles

        load_char
        load_ball

        load_mobs
#        load_bindings

        load_map  # LOAD MAP

        load_sounds

        @bouncing = false
    end 


    def load_panels                     #  LOAD_PANELS    LOAD_PANELS
        header_panel = add_panel(SECTION_NORTH)
        header_panel.get_layout.add_text("OVERLORD",
                                         { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER,
                                           ARG_USE_LARGE_FONT => true})
        subheader_panel = header_panel.get_layout.add_vertical_panel({ARG_LAYOUT => LAYOUT_EAST_WEST,
                                                                      ARG_DESIRED_WIDTH => GAME_WIDTH - 100})
#        subheader_panel.disable_border
        west_panel = subheader_panel.add_panel(SECTION_WEST)
        west_panel.get_layout.add_text("Score")
        @score_text = west_panel.get_layout.add_text("#{@score}")
        
        east_panel = subheader_panel.add_panel(SECTION_EAST)
        east_panel.get_layout.add_text("Level", {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        @level_text = east_panel.get_layout.add_text("#{@level}",
                                                     {ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
    end


    def load_char                          # LOAD_CHAR
        @char = Character.new
        @char.set_absolute_position(500, 150)
        add_child(@char)
    end

    def load_ball                          # LOAD_BALL
        @ball = Ballrag.new
        @ball.speed = 5
        add_child(@ball)
    end

    # def load_bindings
    #     @bindings = KeyBindings.new(@char)
    # end

    def load_map    # LOAD MAP             # LOAD_MAP  __________________

        @worldmap.create_board(File.readlines("maps/maps/a1.txt"))

        add_child(@grid)                    #        ____________________
    end

    #
    #
    #   HANDLE_UPDATE              HANDLE_UPDATE   HANDLE_UPDATE
    #
    def handle_update update_count, mouse_x, mouse_y
        return if @pause
        ball_logic
        move_camera
        collision_detection(children)
        move_mobs
    end
    
    #   MOVE_MOBS                  MOVE_MOBS
    def move_mobs
        @mob1.move_it(@grid)
        @mob2.move_it(@grid)
        @mob3.move_it(@grid)
        @mob4.move_it(@grid)
        @mob5.move_it(@grid)
        @mob6.move_it(@grid)
        @mob7.move_it(@grid)
        @mob8.move_it(@grid)
    end
    def load_mobs                          # LOAD_MOBS
        @mob1 = Mob.new("media/sprites/bat.png")
        @mob2 = Mob.new("media/sprites/blob.png")
        @mob3 = Mob.new("media/sprites/ghost.png")
        @mob4 = Mob.new("media/sprites/ghoul.png")
        @mob5 = Mob.new("media/sprites/ghoul2.png")
        @mob6 = Mob.new("media/sprites/girl.png")
        @mob7 = Mob.new("media/sprites/skeleton.png")
        @mob8 = Mob.new("media/sprites/spider.png")
        @mob1.set_absolute_position(250, 380)
        @mob2.set_absolute_position(300, 380)
        @mob3.set_absolute_position(350, 380)
        @mob4.set_absolute_position(400, 380)
        @mob5.set_absolute_position(450, 380)
        @mob6.set_absolute_position(500, 380)
        @mob7.set_absolute_position(550, 380)
        @mob8.set_absolute_position(600, 380)
        add_child(@mob1)
        add_child(@mob2)
        add_child(@mob3)
        add_child(@mob4)
        add_child(@mob5)
        add_child(@mob6)
        add_child(@mob7)
        add_child(@mob8)
    end


    def render   # RENDER   # RENDER   # RENDER   RENDER   RENDER   DRAW   DRAW   DRAW
    end

    def draw   # DRAW   # DRAW   #  DRAW   DRAW   DRAW   DRAW   DRAW   DRAW
        if @show_border
            draw_border
        end
        @children.each do |child|
            if child.is_a? GridDisplay or child.is_a? Character or 
               child.is_a? Ballrag or child.is_a? Mob
                # skip
            else
                child.draw
            end
        end

        Gosu.translate(-@camera_x, -@camera_y) do
            @grid.draw
            @char.draw
            @ball.draw
            @mob1.draw
            @mob2.draw
            @mob3.draw
            @mob4.draw
            @mob5.draw
            @mob6.draw
            @mob7.draw
            @mob8.draw
        end
    end 

    #   MOVE_CAMERA               # MOVE_CAMERA
    def move_camera
        # Scrolling follows char  # @camera_x = [[@char.x - (GAME_WIDTH.to_f / 2), 0].max, @grid.grid_width * 32 - GAME_WIDTH].min
                                  # @camera_y = [[@char.y - (GAME_HEIGHT.to_f / 2), 0].max, @grid.grid_height * 32 - GAME_HEIGHT].min
        if @char.x >= 1050; @camera_x = 1050
        else @camera_x = 0;
        end

        if @char.y >= 600; @camera_y = 500
        else @camera_y = 0;
        end

        #puts "#{@char.x}, #{@char.y}    Camera: #{@camera_x}, #{@camera_y}"
    end

    def ball_logic              #  BALL_LOGIC   BALL_LOGIC  BALL_LOGIC
        proposed_next_x, proposed_next_y = @ball.proposed_move
        occupant = @grid.proposed_widget_at(@ball, proposed_next_x, proposed_next_y)

        if occupant.empty?

            if @ball.overlaps(proposed_next_x, proposed_next_y, @char)
                puts "ball hit char"
                play_chime
                bounce_off_char(proposed_next_x, proposed_next_y)

            else
                puts "bounce other"
                @ball.set_absolute_position(proposed_next_x, proposed_next_y)
            end

        else 
            #info("Found candidate objects to interact")
            if collision_detection(occupant) #, update_count)
                puts "bounce wall or block"
                @ball.set_absolute_position(proposed_next_x, proposed_next_y) 

                play_beep0
            end
        end
    end

    def action_map(id)
        return 'left' if id == Gosu::KbA or id == Gosu::KbLeft
        return 'right' if id == Gosu::KbD or id == Gosu::KbRight
        return 'up' if id == Gosu::KbW or id == Gosu::KbUp
        return 'down' if id == Gosu::KbS or id == Gosu::KbDown
        return 'kick' if id == Gosu::KbSpace

    end

    def handle_key_held_down(id, mouse_x, mouse_y)
        @char.move_left(@grid) if action_map(id) == 'left'
        @char.move_right(@grid) if action_map(id) == 'right'
        @char.move_up(@grid) if action_map(id) == 'up'
        @char.move_down(@grid) if action_map(id) == 'down'
        puts "key down"
        # puts "#{@char.x}, #{@char.y}    Camera: #{@camera_x}, #{@camera_y}   Tile: #{@grid.tile_at_absolute(@char.x, @char.y)}"
        # @bindings.handle_key_held_down(id, mouse_x, mouse_y)
    end

    def handle_key_press(id, mouse_x, mouse_y)
        @char.press_z if id == Gosu::KbZ
        @char.press_y if id == Gosu::KbY
        @char.press_f if id == Gosu::KbF

        @char.press_q if id == Gosu::KbQ
        @char.press_e if id == Gosu::KbE
        @char.press_r if id == Gosu::KbR
        @char.press_t if id == Gosu::KbT
        @char.press_x if id == Gosu::KbX
        @char.press_c if id == Gosu::KbC
        @char.press_v if id == Gosu::KbV

        @char.press_u if id == Gosu::KbU
        @char.press_i if id == Gosu::KbI
        @char.press_o if id == Gosu::KbO
        @char.press_p if id == Gosu::KbP
        @char.press_g if id == Gosu::KbG
        @char.press_h if id == Gosu::KbH
        @char.press_j if id == Gosu::KbJ
        @char.press_k if id == Gosu::KbK
        @char.press_l if id == Gosu::KbL

        @char.press_b if id == Gosu::KbB
        @char.press_n if id == Gosu::KbN
        @char.press_m if id == Gosu::KbM

        @char.start_move_left if action_map(id) == 'left'
        @char.start_move_right if action_map(id) == 'right'
        @char.start_move_up if action_map(id) == 'up'
        @char.start_move_down if action_map(id) == 'down'
        @char.kick if action_map(id) == 'kick'
        puts "key press"
        # @bindings.handle_key_press(id, mouse_x, mouse_y)
    end


     def load_sounds
         @beep0 = Gosu::Sample.new('media/sounds/beep0.ogg')
         @chime = Gosu::Sample.new('media/sounds/chime.ogg')
         @click_low = Gosu::Sample.new('media/sounds/click_low.ogg')
     end

     #   PLAY_SOUNDS                     # PLAY_SOUNDS    PLAY_SOUNDS   PLAY_SOUNDS
     def play_beep0;    @beep0.play;  end
     def play_chime;    @chime.play;   end
     def play_click_low; @click_low.play;  end


    def handle_key_up(id, mouse_x, mouse_y)
#        @bindings.handle_key_up(id, mouse_x, mouse_y)
        if id == Gosu::KbA or id == Gosu::KbD or id == Gosu::KbW or id == Gosu::KbS or
           id == Gosu::KbLeft or id == Gosu::KbRight or id == Gosu::KbUp or id == Gosu::KbDown
            @char.stop_move
            puts "key up"
        end
    end


    def intercept_widget_event(result)          #  INTERCEPT    INTERCEPT
        info("We intercepted the event #{result.inspect}")
        info("The overlay widget is #{@overlay_widget}")
        if result.close_widget 
            if @game_mode == RDIA_MODE_START
                @game_mode = RDIA_MODE_PLAY
                @pause = false 
            elsif @game_mode == RDIA_MODE_END
                @game_mode = RDIA_MODE_START
            end
        end
        result
    end



######                                  ########
######   BOUNCE     BOUNCE   BOUNCE     ########
######                                  ########
    def is_bouncing?(w)
        true if x_bounce?(w)
        true if y_bounce?(w)
    end

    def x_bounce?(w)
        true if @ball.center_y >= w.y and @ball.center_y <= w.bottom_edge
    end
    def y_bounce?(w)
        true if @ball.center_x >= w.x and @ball.center_x <= w.right_edge
    end

    def square_bounce(w)
        @ball.speed = 40
        if is_bouncing?(w)
            @bouncing = true
            @ball.bounce_y if y_bounce?(w)
#            puts "bounce_y" if y_bounce?(w)
            @ball.bounce_x if x_bounce?(w)
#            puts "bounce_x" if x_bounce?(w)
        else 
#            info("wall doesnt know how to bounce ball. #{w.x}  #{@ball.center_x}  #{w.right_edge}")
            quad = @ball.relative_quad(w)
#            info("Going to bounce off relative quad #{quad}")
            gdd = nil
            if quad == QUAD_NW 
                gdd = @ball.x_or_y_dimension_greater_distance(w.x, w.y)        
            elsif quad == QUAD_NE
                gdd = @ball.x_or_y_dimension_greater_distance(w.right_edge, w.y)
            elsif quad == QUAD_SE
                gdd = @ball.x_or_y_dimension_greater_distance(w.right_edge, w.bottom_edge)
            elsif quad == QUAD_SW
                gdd = @ball.x_or_y_dimension_greater_distance(w.x, w.bottom_edge)
            else 
                info("ERROR adjust for ball accel from quad #{quad}")
            end

            if gdd == X_DIM
                @ball.bounce_x
                @ball.speed = 10
            else 
                # Right now, if it is not defined, one of the diagonal quadrants
                # we are bouncing on the y dimension.
                # Not technically accurate, but probably good enough for now
                @ball.bounce_y
                @ball.speed = 10
            end
        end
    end 

    def diagonal_bounce(w)
        if @ball.direction > DEG_360 
            raise "ERROR ball radians are above double pi #{@ball.direction}. Cannot adjust triangle accelerations"
        end

        axis = AXIS_VALUES[w.orientation]
        if @ball.will_hit_axis(axis)
            #puts "Triangle bounce"
            @ball.bounce(axis)
        else 
            #puts "Square bounce"
            square_bounce(w)
        end
    end 

    def bounce_off_char(proposed_next_x, proposed_next_y)
        puts "bounce_off_char"
        in_radians = @ball.direction
        cx = @ball.center_x 
        scale_length = @char.width + @ball.width
        impact_on_scale = ((@char.right_edge + (@ball.width / 2)) - cx) + 0.25
        pct = impact_on_scale.to_f / scale_length.to_f
        @ball.direction = 0.15 + (pct * (Math::PI - 0.3.to_f))
        #info("Scale length: #{scale_length}  Impact on Scale: #{impact_on_scale.round}  Pct: #{pct.round(2)}  rad: #{@ball.direction.round(2)}  speed: #{@ball.speed}")
        #info("#{impact_on_scale.round}/#{scale_length}:  #{pct.round(2)}%")
        @ball.last_element_bounce = @char.object_id
        # if @progress_bar.is_done
        #     @update_fire_after_next_player_hit = true 
        # end
    end

    def tilt 
        r = ((rand(10) * 0.01) - 0.05) * 20
        @ball.direction = @ball.direction + r
    end

    def pause_game          # PAUSE
        if @pause 
            return 
        end 
        @pause = true 
#        @progress_bar.stop
    end 

    def restart_game        # RESTART
        @pause = false 
#        @progress_bar.start
    end 



    ###########################
    #                         #
    #   COLLISION_DETECTION   #
    #                         #
    def collision_detection(objects)      #  INTERACT     INTERACT
        if objects.size == 1
            w = objects[0]
            if w.object_id == @ball.last_element_bounce
                # Don't bounce off the same element twice
                w = nil 
            end
        else 
            # Choose the widget with the shortest distance from the center of the ball
            closest_widget = nil 
            closest_distance = 100   # some large number
            objects.each do |candidate_widget| 
                d = @ball.distance_between_center_mass(candidate_widget)
                debug("Comparing #{d} with #{closest_distance}. Candidate #{candidate_widget.object_id}  last bounce: #{@ball.last_element_bounce}")
                if d < closest_distance and candidate_widget.object_id != @ball.last_element_bounce
                    closest_distance = d 
                    closest_widget = candidate_widget 
                end 
            end 
            w = closest_widget
        end
        if w.nil?
            return true
        end

        puts "collision detection'"
        puts "Reaction #{w.interaction_results} with widget #{w}"




        @ball.last_element_bounce = w.object_id

        if w.interaction_results.include? RDIA_REACT_STOP 
            @ball.stop_move
        end

        if w.interaction_results.include? RDIA_REACT_LOSE 
            @pause = true
            @game_mode = RDIA_MODE_END
            if @overlay_widget.nil?
                add_overlay(create_you_lose_widget)
            end
        end

        if w.interaction_results.include? RDIA_REACT_BOUNCE 
            square_bounce(w)
        elsif w.interaction_results.include? RDIA_REACT_BOUNCE_DIAGONAL
            diagonal_bounce(w)
        end

        if w.interaction_results.include? RDIA_REACT_CONSUME
            @grid.remove_tile_at_absolute(w.x + 1, w.y + 1)
        end

        if w.interaction_results.include? RDIA_REACT_GOAL
            # TODO end this round
        end

        if w.interaction_results.include? RDIA_REACT_SCORE
            @score = @score + w.score
            @score_text.label = "#{@score}"
        end

        if w.interaction_results.include? RDIA_REACT_GOAL
            @pause = true
            @game_mode = RDIA_MODE_END
            if @overlay_widget.nil?
                add_overlay(create_you_win_widget)
            end
        end
        true

    end


end ### end class Scroller ###
