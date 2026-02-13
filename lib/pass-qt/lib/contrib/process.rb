module Contrib
  class Process < RubyQt6::Bando::QObject
    q_object do
      slot "_on_process_error_occurred(QProcess::ProcessError)"
      slot "_on_process_finished(int,QProcess::ExitStatus)"
    end

    def self.execute(program, arguments, **kwargs)
      new._execute(program, arguments, **kwargs)
    end

    def _execute(program, arguments, stdin: nil, envs: nil, on_success: nil, on_failure: nil)
      process = QProcess.new
      @on_success = on_success
      @on_failure = on_failure

      if envs
        process_env = QProcessEnvironment.system_environment
        envs.each { |k, v| process_env.insert(k.to_s, v.to_s) }
        process.set_process_environment(process_env)
      end

      process.start(program, arguments)
      process.write(stdin.to_s) if stdin
      process.close_write_channel
      process.error_occurred.connect(self, :_on_process_error_occurred)
      process.finished.connect(self, :_on_process_finished)
    end

    private

    def _on_process_error_occurred(error)
      process = sender
      data = {"code" => nil, "stdout" => "", "stderr" => error.to_s}
      @on_failure&.call(data)
    ensure
      process.delete_later
    end

    def _on_process_finished(code, status)
      process = sender
      stdout = process.read_all_standard_output.to_s
      stderr = process.read_all_standard_error.to_s
      data = {"code" => code, "stdout" => stdout, "stderr" => stderr}

      if status != QProcess::NormalExit
        @on_failure&.call(data)
      elsif code != 0
        @on_failure&.call(data)
      else
        @on_success&.call(data)
      end
    ensure
      process.delete_later
    end
  end
end
