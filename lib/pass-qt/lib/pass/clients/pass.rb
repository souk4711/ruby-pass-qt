module Pass
  module Clients
    class Pass
      def initialize
        @program = "pass"
      end

      def show(store, passname, on_success:, on_failure:)
        arguments = QStringList.new << "show" << passname
        envs = {PASSWORD_STORE_DIR: store}
        Contrib::Process.execute(@program, arguments, envs:, on_success:, on_failure:)
      end

      def insert(store, passname, password, extra, on_success:, on_failure:)
        arguments = QStringList.new << "insert" << "-m" << passname
        stdin = "#{password}\n#{extra}"
        envs = {PASSWORD_STORE_DIR: store}
        Contrib::Process.execute(@program, arguments, stdin:, envs:, on_success:, on_failure:)
      end

      def otp(store, passname, on_success:, on_failure:)
        arguments = QStringList.new << "otp" << passname
        envs = {PASSWORD_STORE_DIR: store}
        Contrib::Process.execute(@program, arguments, envs:, on_success:, on_failure:)
      end

      def otp_insert(store, passname, password, on_success:, on_failure:)
        arguments = QStringList.new << "otp" << "insert" << passname
        stdin = password
        envs = {PASSWORD_STORE_DIR: store}
        Contrib::Process.execute(@program, arguments, stdin:, envs:, on_success:, on_failure:)
      end

      def pwgen(pw_length, on_success:, on_failure:)
        arguments = QStringList.new << "-cnysB" << pw_length.to_s << "1"
        Contrib::Process.execute("pwgen", arguments, on_success:, on_failure:)
      end
    end
  end
end
