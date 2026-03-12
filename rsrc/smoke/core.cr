require "../../src/raylib-cr"

Raylib.set_config_flags(Raylib::ConfigFlags::WindowHidden)
Raylib.init_window(64, 64, "raylib-cr smoke")

raise "window did not initialize" unless Raylib.window_ready?
raise "screen width invalid" unless Raylib.get_screen_width > 0
raise "screen height invalid" unless Raylib.get_screen_height > 0

mouse = Raylib.get_mouse_position
raise "mouse position invalid" unless mouse.x.finite? && mouse.y.finite?

Raylib.begin_drawing
Raylib.clear_background(Raylib::BLACK)
Raylib.end_drawing
Raylib.close_window
