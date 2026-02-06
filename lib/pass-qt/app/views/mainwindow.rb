module PassQt
  class MainWindow < RubyQt6::Bando::QMainWindow
    q_object do
    end

    def initialize
      super

      initialize_toolbar
      initialize_central_widget

      settings = QSettings.new
      restore_geometry(settings.value("MainWindow/geometry", QByteArray.new("")))
      restore_state(settings.value("MainWindow/windowState", QByteArray.new("")))
    end

    def close_event(evt)
      settings = QSettings.new
      settings.set_value("MainWindow/geometry", save_geometry)
      settings.set_value("MainWindow/windowState", save_state)

      _close_event(evt)
    end

    private

    def initialize_toolbar
    end

    def initialize_central_widget
      @passlistwidget = PassListWidget.new
      @passinfowidget = PassInfoWidget.new

      centralwidget = QWidget.new
      mainlayout = QHBoxLayout.new(centralwidget)
      mainlayout.add_widget(@passlistwidget)
      mainlayout.add_widget(@passinfowidget)
      mainlayout.set_stretch(0, 2)
      mainlayout.set_stretch(1, 3)

      set_central_widget(centralwidget)
    end
  end
end
