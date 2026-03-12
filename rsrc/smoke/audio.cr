require "../../src/raylib-cr/audio"

# Compile smoke for the audio bindings. Runtime audio init remains part of
# manual validation because CI environments vary widely in device availability.
puts RAudio::MusicContextType::AudioNone.value
