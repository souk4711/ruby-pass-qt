require_relative "pass/backend"
require_relative "pass/process"

module Pass
  def self.show(store, passname, on_success:, on_failure:)
    backend.show(store, passname, on_success:, on_failure:)
  end

  def self.insert(store, passname, password, extra, on_success:, on_failure:)
    backend.insert(store, passname, password, extra, on_success:, on_failure:)
  end

  def self.otp(store, passname, on_success:, on_failure:)
    backend.otp(store, passname, on_success:, on_failure:)
  end

  def self.otp_insert(store, passname, password, on_success:, on_failure:)
    backend.otp_insert(store, passname, password, on_success:, on_failure:)
  end

  def self.pwgen(pw_length, on_success:, on_failure:)
    backend.pwgen(pw_length, on_success:, on_failure:)
  end

  def self.backend
    @backend ||= lambda do
      [
        ["pass", ::Pass::Backend::Pass],
        ["gopass", ::Pass::Backend::GoPass]
      ].each do |program, klass|
        r = QProcess.execute(program, QStringList.new << "--version")
        return klass.new if r.zero?
      end

      ::Pass::Backend::Pass.new
    end.call
  end
  private_class_method :backend
end
