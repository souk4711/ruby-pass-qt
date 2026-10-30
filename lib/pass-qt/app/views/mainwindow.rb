require_relative "mainwindow/components"
require_relative "mainwindow/ui"

class MainWindow < RubyQt6::Bando::QMainWindow
  q_object do
    slot "_on_browse_action_triggered()"
  end

  def initialize
    super

    initialize_ui
    PassQt.settings.GET_mainwindow_geometry_and_restore_to(self)
  end

  def close_event(evt)
    PassQt.settings.PUT_mainwindow_geometry(self)
    _close_event(evt)
  end

  private

  def _on_browse_action_triggered
    dialog = BrowseStoresDialog.new
    dialog.stores_changed.connect(@passlistwidget, :refresh)
    dialog.show
  end
end
