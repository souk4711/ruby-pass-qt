class PassInfoWidget < RubyQt6::Bando::QWidget
  private

  def parse_passfile(data)
    lines = data["stdout"].lines
    password = lines[0][..-2]

    username = ""
    website = ""
    lines.each do |line|
      matched = line.match(/\A(\w+:\s*)?(.*)\n/)
      next if matched.nil?

      case matched[1]&.rstrip&.downcase
      when "username:" then username = matched[2]
      when "website:" then website = matched[2]
      end
    end

    {
      "password" => password,
      "username" => username,
      "website" => website
    }
  end
end
