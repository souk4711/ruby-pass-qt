module PassQt
  class MainWindow < RubyQt6::Bando::QMainWindow
    q_object do
      slot "_on_passlistwidget_passfile_changed(QString,QString)"
    end

    def initialize
      super

      initialize_toolbar
      initialize_central_widget

      PassQt.settings.GET_mainwindow_geometry_and_restore_to(self)
    end

    def close_event(evt)
      PassQt.settings.PUT_mainwindow_geometry(self)

      _close_event(evt)
    end

    private

    def initialize_toolbar
    end

    def initialize_central_widget
      @passlistwidget = PassListWidget.new
      @passinfowidget = PassInfoWidget.new
      @passlistwidget.passfile_changed.connect(self, :_on_passlistwidget_passfile_changed)

      centralwidget = QWidget.new
      mainlayout = QHBoxLayout.new(centralwidget)
      mainlayout.add_widget(@passlistwidget)
      mainlayout.add_widget(@passinfowidget)
      mainlayout.set_stretch(0, 2)
      mainlayout.set_stretch(1, 3)

      set_central_widget(centralwidget)
    end

    def _on_passlistwidget_passfile_changed(store, passname)
      @passinfowidget.reinitialize_passfile(store, passname)
    end
  end
end
