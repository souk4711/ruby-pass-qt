class MainWindow < RubyQt6::Bando::QMainWindow
  private

  def initialize_ui
    initialize_toolbar
    initialize_central_widget

    set_context_menu_policy(Qt::NoContextMenu)
  end

  def initialize_toolbar
    browse_action = QAction.new(QIcon.from_theme(QIcon::ThemeIcon::Computer), "Browse", self)
    browse_action.set_tool_tip("Browse password stores")
    browse_action.triggered.connect(self, :_on_browse_action_triggered)

    toolbar = add_tool_bar("ToolBar")
    toolbar.set_object_name("mainwindow_toolbar")
    toolbar.set_movable(false)
    toolbar.add_action(browse_action)
  end

  def initialize_central_widget
    @passlistwidget = MainWindowPassListWidget.new
    @passinfowidget = MainWindowPassInfoWidget.new

    @passlistwidget.store_changed.connect(@passinfowidget, :activate_infocard)
    @passlistwidget.nil_selected.connect(@passinfowidget, :activate_infocard)
    @passlistwidget.passfile_selected.connect(@passinfowidget, :activate_passfilecard)
    @passlistwidget.passfolder_selected.connect(@passinfowidget, :activate_passfoldercard)

    centralwidget = QWidget.new
    mainlayout = QHBoxLayout.new(centralwidget)
    mainlayout.add_widget(@passlistwidget)
    mainlayout.add_widget(@passinfowidget)
    mainlayout.set_stretch(0, 2)
    mainlayout.set_stretch(1, 3)
    set_central_widget(centralwidget)
  end
end
