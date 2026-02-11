module PassQt
  class MainWindow < RubyQt6::Bando::QMainWindow
    q_object do
      slot "_on_browse_action_triggered()"
      slot "_on_browsestoresdialog_stores_changed()"
      slot "_on_passlistwidget_store_changed(QString)"
      slot "_on_passlistwidget_passfile_selected(QString,QString)"
      slot "_on_passlistwidget_passfolder_selected(QString,QString)"
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
      browse_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::Computer), "Browse")
      browse_action.set_tool_tip("Browse password stores")
      browse_action.triggered.connect(self, :_on_browse_action_triggered)

      toolbar = add_tool_bar("ToolBar")
      toolbar.set_object_name("ToolBar")
      toolbar.set_movable(false)
      toolbar.add_action(browse_action)
    end

    def initialize_central_widget
      @passlistwidget = PassListWidget.new
      @passlistwidget.store_changed.connect(self, :_on_passlistwidget_store_changed)
      @passlistwidget.passfile_selected.connect(self, :_on_passlistwidget_passfile_selected)
      @passlistwidget.passfolder_selected.connect(self, :_on_passlistwidget_passfolder_selected)

      @passinfowidget = PassInfoWidget.new

      centralwidget = QWidget.new
      mainlayout = QHBoxLayout.new(centralwidget)
      mainlayout.add_widget(@passlistwidget)
      mainlayout.add_widget(@passinfowidget)
      mainlayout.set_stretch(0, 2)
      mainlayout.set_stretch(1, 3)

      set_central_widget(centralwidget)
    end

    def _on_browse_action_triggered
      dialog = BrowseStoresDialog.new
      dialog.stores_changed.connect(self, :_on_browsestoresdialog_stores_changed)
      dialog.show
    end

    def _on_browsestoresdialog_stores_changed
      @passlistwidget.reinitialize_stores
    end

    def _on_passlistwidget_store_changed(store)
      @passinfowidget.reinitialize_passfolder(store, "")
    end

    def _on_passlistwidget_passfile_selected(store, passname)
      @passinfowidget.reinitialize_passfile(store, passname)
    end

    def _on_passlistwidget_passfolder_selected(store, passname)
      @passinfowidget.reinitialize_passfolder(store, passname)
    end
  end
end
