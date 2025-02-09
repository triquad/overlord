
class OverTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_BORDER_BLUE,          # border color
              COLOR_LIGHT_GRAY,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              # Gosu::Font.new(40,  :name => "TimesNewRoman"),   # regular font
              # Gosu::Font.new(50,  :name => "Consolas") )  # large font
              Gosu::Font.new(30, {:name => "media/MutatorSans.ttf"}),  # regular font
              Gosu::Font.new(80, {:name => "media/MutatorSans.ttf"}))  # large font
    end

end

class BricksTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_BORDER_BLUE,          # border color
              COLOR_BLACK,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              Gosu::Font.new(22, {:name => media_path("armalite_rifle.ttf")}),  # regular font
              Gosu::Font.new(38, {:name => media_path("armalite_rifle.ttf")}))  # large font
    end

    def media_path(file)
        File.join(File.dirname(File.dirname(__FILE__)), 'overlord/media', file)
    end
end

class OverlayTheme < GuiTheme
    def initialize
        super(COLOR_WHITE,                # text color
              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
              COLOR_VERY_LIGHT_BLUE,      # border color
              COLOR_BLACK,                # background
              COLOR_LIGHT_GRAY,           # selected item
              true,                       # use icons
              Gosu::Font.new(22),  # regular font
              Gosu::Font.new(38))  # large font
    end

    def media_path(file)
        File.join(File.dirname(File.dirname(__FILE__)), 'media', file)
    end
end

def create_overlay_widget
    InfoBox.new(100, 60, 600, 400, "Welcome to Ruby Bricks", overlay_content, { ARG_THEME => BricksTheme.new})
end

def overlay_content
    <<~HEREDOC
    Your goal is to clear all of the bricks and dots
    without letting the ball drop through to the bottom.
    Hit the 'W' button to get started.
    HEREDOC
end

def create_you_lose_widget
    InfoBox.new(100, 60, 600, 400, "Sorry, you lost", you_lose_content, { ARG_THEME => BricksTheme.new})
end

def you_lose_content
    <<~HEREDOC
    Try not to let the ball fall through next time.
    HEREDOC
end

def create_you_win_widget
    InfoBox.new(100, 60, 600, 400, "You win!", you_win_content, { ARG_THEME => WadsDarkRedBrownTheme.new})
end

def you_win_content
    <<~HEREDOC
    You did it. That was amazing!
    Nice work.
    HEREDOC
end

# WadsConfig.instance.set_current_theme(OverTheme.new)
