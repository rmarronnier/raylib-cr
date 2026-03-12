require "./spec_helper"

describe "Raylib" do
  it "exposes the reconciled 5.5 version string" do
    Raylib::VERSION.should eq("5.5")
  end
end
