require "../../src/raylib-cr"
require "../../src/raylib-cr/raygui"
require "../../src/raylib-cr/rlgl"
require "../../src/raylib-cr/audio"
require "../../src/raylib-cr/lights"

puts [
  Raylib::VERSION,
  Raygui::VERSION,
  RLGL::TEXTURE_WRAP_S,
  RAudio::MusicContextType::AudioNone.value,
  Raylib::Lights::MAX,
].join(":")
