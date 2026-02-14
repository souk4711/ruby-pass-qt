module Pass
  def self.show(store, passname, on_success:, on_failure:)
    arguments = QStringList.new << "show" << passname
    envs = {PASSWORD_STORE_DIR: store}
    Contrib::Process.execute("pass", arguments, envs:, on_success:, on_failure:)
  end

  def self.insert(store, passname, password, extra, on_success:, on_failure:)
    arguments = QStringList.new << "insert" << "-m" << passname
    stdin = "#{password}\n#{extra}"
    envs = {PASSWORD_STORE_DIR: store}
    Contrib::Process.execute("pass", arguments, stdin:, envs:, on_success:, on_failure:)
  end

  def self.otp(store, passname, on_success:, on_failure:)
    arguments = QStringList.new << "otp" << passname
    envs = {PASSWORD_STORE_DIR: store}
    Contrib::Process.execute("pass", arguments, envs:, on_success:, on_failure:)
  end

  def self.otp_insert(store, passname, password, on_success:, on_failure:)
    arguments = QStringList.new << "otp" << "insert" << passname
    stdin = password
    envs = {PASSWORD_STORE_DIR: store}
    Contrib::Process.execute("pass", arguments, stdin:, envs:, on_success:, on_failure:)
  end

  def self.pwgen(pw_length, on_success:, on_failure:)
    arguments = QStringList.new << "-cnysB" << pw_length.to_s << "1"
    Contrib::Process.execute("pwgen", arguments, on_success:, on_failure:)
  end
end
