module PassQt
  class PassInfoWidget < RubyQt6::Bando::QWidget
    q_object do
    end

    def reinitialize_passfile(store, passname)
      Pass.show(store, passname, on_success: ->(data) {
        puts "on_success: #{data}"
      }, on_failure: ->(data) {
        puts "on_failure: #{data}"
      })
    end
  end
end
