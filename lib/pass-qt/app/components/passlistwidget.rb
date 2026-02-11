require_relative "passlistwidget/treewidget"

module PassQt
  class PassListWidget < RubyQt6::Bando::QWidget
    q_object do
      signal "store_changed(QString)"
      signal "passfile_selected(QString,QString)"
      signal "passfolder_selected(QString,QString)"
      slot "_on_combobox_current_text_changed(QString)"
      slot "_on_searchbar_text_changed(QString)"
    end

    def initialize
      super

      initialize_combobox
      initialize_searchbar
      initialize_treewidget

      mainlayout = QVBoxLayout.new(self)
      mainlayout.add_layout(@comboboxlayout)
      mainlayout.add_widget(@searchbar)
      mainlayout.add_widget(@treewidget)

      update_combobox
    end

    def reinitialize_stores
      @combobox.block_signals(true).tap do |blocked|
        @combobox.clear
      ensure
        @combobox.block_signals(blocked)
      end

      update_combobox
    end

    private

    def initialize_combobox
      @combobox = QComboBox.new
      @combobox.current_text_changed.connect(self, :_on_combobox_current_text_changed)

      @comboboxlayout = QHBoxLayout.new
      @comboboxlayout.add_widget(QLabel.new("Current Store"))
      @comboboxlayout.add_widget(@combobox)
      @comboboxlayout.set_stretch(0, 2)
      @comboboxlayout.set_stretch(1, 3)
    end

    def initialize_searchbar
      @searchbar = QLineEdit.new
      @searchbar.set_placeholder_text("List passwords that match passname...")
      @searchbar.text_changed.connect(self, :_on_searchbar_text_changed)
    end

    def initialize_treewidget
      @treewidget = TreeWidget.new
      @treewidget.set_header_hidden(true)
      @treewidget.passfile_selected.connect(self, :passfile_selected)
      @treewidget.passfolder_selected.connect(self, :passfolder_selected)
    end

    def update_combobox
      PassQt.settings.GET_stores.each do |store|
        fileinfo = QFileInfo.new(store["fullpath"])
        @combobox.add_item(fileinfo.file_name, QVariant.new(fileinfo.absolute_file_path))
      end
    end

    def _on_combobox_current_text_changed(_text)
      store = @combobox.current_data.value

      @treewidget.reinitialize_store(store)
      @treewidget.expand_all
      store_changed.emit(store)

      @searchbar.clear
      QTimer.single_shot(0, @searchbar, :set_focus)
    end

    def _on_searchbar_text_changed(text)
      @treewidget.search_passfile(text)
    end
  end
end
