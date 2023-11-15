module ChatGPT
  module Launcher
    extend self

    def open_editor(file_name)
      editor = if ENV.has_key?("EDITOR")
                 ENV["EDITOR"]
               else
                 {% if flag?(:win32) %}
                   "notepad"
                 {% else %}
                   "vim"
                 {% end %}
               end
      system("#{editor} #{file_name}")
    end

    def open_browser(file_name)
      {% if flag?(:linux) %}
        system("xdg-open #{file_name}")
      {% elsif flag?(:darwin) %}
        system("open #{file_name}")
      {% elsif flag?(:win32) %}
        system("cmd /c start #{file_name}")
      {% end %}
    end
  end
end
