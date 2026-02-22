module Pass
  module Clients
    class GoPass < ::Pass::Clients::Pass
      def initialize
        @program = "gopass"
      end

      def otp_insert(store, passname, password, on_success:, on_failure:)
        arguments = QStringList.new << "insert" << passname
        stdin = password
        envs = {PASSWORD_STORE_DIR: store}
        Contrib::Process.execute(@program, arguments, stdin:, envs:, on_success:, on_failure:)
      end

      def pwgen(pw_length, on_success:, on_failure:)
        arguments = QStringList.new << "pwgen" << "-By1" << pw_length.to_s
        Contrib::Process.execute(@program, arguments, on_success:, on_failure:)
      end
    end
  end
end
