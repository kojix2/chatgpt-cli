module ChatGPT
  class MagicCommand
    def html_data
      html = HtmlGenerator.new(data).to_s
      timestamp = Time.local.to_s("%Y%m%d-%H%M%S")
      file_name = "chatgpt-#{timestamp}.html"
      html_data(file_name)
    end

    def html_data(file_name)
      html = HtmlGenerator.new(data).to_s
      File.write(file_name, html)
      open_browser(file_name)
      # file.delete   # FIXME: delete file
      true
    end
  end
end
