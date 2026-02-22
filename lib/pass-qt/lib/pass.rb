require_relative "pass/clients"

module Pass
  def self.show(store, passname, on_success:, on_failure:)
    client.show(store, passname, on_success:, on_failure:)
  end

  def self.insert(store, passname, password, extra, on_success:, on_failure:)
    client.insert(store, passname, password, extra, on_success:, on_failure:)
  end

  def self.otp(store, passname, on_success:, on_failure:)
    client.otp(store, passname, on_success:, on_failure:)
  end

  def self.otp_insert(store, passname, password, on_success:, on_failure:)
    client.otp_insert(store, passname, password, on_success:, on_failure:)
  end

  def self.pwgen(pw_length, on_success:, on_failure:)
    client.pwgen(pw_length, on_success:, on_failure:)
  end

  def self.client
    @client ||= lambda do
      [
        ["pass", ::Pass::Clients::Pass],
        ["gopass", ::Pass::Clients::GoPass]
      ].each do |program, klass|
        r = QProcess.execute(program, QStringList.new << "--version")
        return klass.new if r.zero?
      end

      ::Pass::Clients::Pass.new
    end.call
  end
end
