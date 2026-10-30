require_relative "mainwindow/components"
require_relative "mainwindow/ui"

class MainWindow < RubyQt6::Bando::QMainWindow
  q_object do
    slot "_on_browse_action_triggered()"
    slot "_on_browsestoresdialog_stores_changed()"
    slot "_on_passlistwidget_store_changed(QString)"
    slot "_on_passlistwidget_nil_selected(QString)"
    slot "_on_passlistwidget_passfile_selected(QString,QString)"
    slot "_on_passlistwidget_passfolder_selected(QString,QString)"
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
    dialog.stores_changed.connect(self, :_on_browsestoresdialog_stores_changed)
    dialog.show
  end

  def _on_browsestoresdialog_stores_changed
    @passlistwidget.refresh
  end

  def _on_passlistwidget_store_changed(_store)
    @passinfowidget.use_infocard
  end

  def _on_passlistwidget_nil_selected(_store)
    @passinfowidget.use_infocard
  end

  def _on_passlistwidget_passfile_selected(store, passname)
    @passinfowidget.use_passfilecard(store, passname)
  end

  def _on_passlistwidget_passfolder_selected(store, passname)
    @passinfowidget.use_passfoldercard(store, passname)
  end
end
