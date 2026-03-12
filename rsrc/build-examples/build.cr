require "file_utils"

repo_root = File.expand_path("..", File.dirname(__DIR__))
native_lib_dir = File.join(repo_root, "libs")

FileUtils.cd("examples") do
  puts "BUILDING EXAMPLE FROM #{FileUtils.pwd}"
  begin
    FileUtils.rm_r("_build")
  rescue
  end
  FileUtils.mkdir_p("_build/rsrc")
  Dir.entries(FileUtils.pwd).each do |name|
    path = Path[name]
    next if path.basename =~ /^\.{1,2}$/ || path.basename =~ /^_build$/

    puts "BUILDING EXAMPLE #{path.basename}"

    FileUtils.cd(path) do
      `shards install`

      windows = ""
      extra_link_flags = [] of String

      if Dir.exists?(native_lib_dir)
        extra_link_flags << "-L#{native_lib_dir}"
      end

      {% if flag?(:windows) %}
        windows = "--link-flags --subsystem:windows"
      {% end %}

      unless extra_link_flags.empty?
        windows = "--link-flags \"#{extra_link_flags.join(" ")}#{windows.empty? ? "" : " --subsystem:windows"}\""
      end

      output = `crystal build --release -s -p -t -o ../_build/#{path.basename} ./src/#{path.basename}.cr #{windows}`

      file = "../_build/#{name}"
      {% if flag?(:windows) %}
        file = "../_build/#{name}.exe"
      {% end %}

      unless File.exists?(file)
        puts output
        puts
        puts "Could not find #{FileUtils.pwd}/_build/#{name}.exe"
        exit(1)
      end

      begin
        FileUtils.rm("../_build/#{name}.pdb")
      rescue
      end

      begin
        FileUtils.cp_r("./rsrc", "../_build/")
      rescue
      end
    end

    {% if flag?(:windows) %}
      if File.exists?(File.join(native_lib_dir, "raylib.dll"))
        FileUtils.cp(File.join(native_lib_dir, "raylib.dll"), "_build/raylib.dll")
      end
      if File.exists?(File.join(native_lib_dir, "raygui.dll"))
        FileUtils.cp(File.join(native_lib_dir, "raygui.dll"), "_build/raygui.dll")
      end
    {% end %}
  end
end
