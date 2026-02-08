require_relative "passlistwidget/treewidget"

module PassQt
  class PassListWidget < RubyQt6::Bando::QWidget
    q_object do
      signal "passfile_changed(QString,QString)"
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

      PassQt.settings.GET_stores.each do |store|
        fileinfo = QFileInfo.new(store["fullpath"])
        @combobox.add_item(fileinfo.file_name, QVariant.new(fileinfo.absolute_file_path))
      end
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
      @searchbar.text_changed.connect(self, :_on_searchbar_text_changed)
    end

    def initialize_treewidget
      @treewidget = TreeWidget.new
      @treewidget.set_header_hidden(true)
      @treewidget.passfile_changed.connect(self, :passfile_changed)
    end

    def _on_combobox_current_text_changed(_text)
      @treewidget.reinitialize_store(@combobox.current_data.value)
      @treewidget.expand_all

      @searchbar.clear
      QTimer.single_shot(0, @searchbar, :set_focus)
    end

    def _on_searchbar_text_changed(text)
      @treewidget.search_passfile(text)
    end
  end
end
