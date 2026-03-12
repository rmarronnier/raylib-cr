require "./spec_helper"

module CallbackHarness
  @@saved_text = ""
  @@saved_data = Bytes.empty

  def self.saved_text : String
    @@saved_text
  end

  def self.saved_text=(value : String)
    @@saved_text = value
  end

  def self.saved_data : Bytes
    @@saved_data
  end

  def self.saved_data=(value : Bytes)
    @@saved_data = value
  end
end

describe "Raylib" do
  it "exposes the reconciled 5.5 version string" do
    Raylib::VERSION.should eq("5.5")
  end

  it "supports custom text file callbacks" do
    save_text_cb = ->(file_name : LibC::Char*, text : LibC::Char*) do
      CallbackHarness.saved_text = String.new(text)
      true
    end

    load_text_cb = ->(file_name : LibC::Char*) do
      text = "loaded from callback"
      ptr = Raylib.mem_alloc((text.bytesize + 1).to_u32).as(LibC::Char*)
      ptr.copy_from(text.to_unsafe, text.bytesize)
      ptr[text.bytesize] = 0
      ptr
    end

    Raylib.set_save_file_text_callback(save_text_cb)
    Raylib.set_load_file_text_callback(load_text_cb)

    Raylib.save_file_text?("ignored.txt".to_unsafe, "saved through callback".to_unsafe).should be_true
    CallbackHarness.saved_text.should eq("saved through callback")

    text_ptr = Raylib.load_file_text("ignored.txt".to_unsafe)
    String.new(text_ptr).should eq("loaded from callback")
    Raylib.unload_file_text(text_ptr)
  end

  it "supports custom binary file callbacks" do
    save_data_cb = ->(file_name : LibC::Char*, data : Void*, data_size : LibC::Int) do
      CallbackHarness.saved_data = Slice.new(data.as(UInt8*), data_size).dup
      true
    end

    load_data_cb = ->(file_name : LibC::Char*, data_size : LibC::Int*) do
      bytes = Bytes[9_u8, 8_u8, 7_u8]
      data_size.value = bytes.size
      ptr = Raylib.mem_alloc(bytes.size.to_u32).as(UInt8*)
      ptr.copy_from(bytes.to_unsafe, bytes.size)
      ptr
    end

    Raylib.set_save_file_data_callback(save_data_cb)
    Raylib.set_load_file_data_callback(load_data_cb)

    bytes = Bytes[1_u8, 2_u8, 3_u8]
    Raylib.save_file_data?("ignored.bin".to_unsafe, bytes.to_unsafe.as(Void*), bytes.size).should be_true
    CallbackHarness.saved_data.should eq(bytes)

    size = 0
    data_ptr = Raylib.load_file_data("ignored.bin".to_unsafe, pointerof(size))
    Slice.new(data_ptr, size).to_a.should eq([9_u8, 8_u8, 7_u8])
    Raylib.unload_file_data(data_ptr)
  end
end
