module PassQt
  class Settings
    def self.save_window_geometry(widget)
      groupname = widget.class.name.split("::").last

      settings = QSettings.new
      settings.set_value("#{groupname}/geometry", widget.save_geometry)
      settings.set_value("#{groupname}/windowState", widget.save_state)
    end

    def self.restore_window_geometry(widget)
      groupname = widget.class.name.split("::").last

      settings = QSettings.new
      widget.restore_geometry(settings.value("#{groupname}/geometry", QByteArray.new("")))
      widget.restore_state(settings.value("#{groupname}/windowState", QByteArray.new("")))
    end
  end
end
