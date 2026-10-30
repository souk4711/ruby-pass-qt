require_relative "passlistwidget/treewidget"
require_relative "passlistwidget/ui"

class MainWindowPassListWidget < RubyQt6::Bando::QWidget
  q_object do
    signal "store_changed(QString)"
    signal "nil_selected(QString)"
    signal "passfile_selected(QString,QString)"
    signal "passfolder_selected(QString,QString)"
    slot "_on_combobox_current_text_changed(QString)"
    slot "_on_searchbar_text_changed(QString)"
  end

  def initialize
    super

    initialize_ui
  end

  def refresh
    @combobox.block_signals(true).tap do |blocked|
      @combobox.clear
    ensure
      @combobox.block_signals(blocked)
    end
    update_combobox_using_settings_stores
  end

  private

  def _on_combobox_current_text_changed(_text)
    store = @combobox.current_data.value
    store_changed.emit(store)

    @searchbar.clear
    QTimer.single_shot(0, @searchbar, :set_focus)

    @treewidget.refresh(store)
  end

  def _on_searchbar_text_changed(text)
    @treewidget.update_passname_filter(text)
  end
end
