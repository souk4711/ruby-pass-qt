module Pass
  def self.show(store, passname, on_success:, on_failure:)
    arguments = QStringList.new << "show" << passname
    envs = {PASSWORD_STORE_DIR: store}
    Contrib::Process.execute("pass", arguments, envs:, on_success:, on_failure:)
  end
end
