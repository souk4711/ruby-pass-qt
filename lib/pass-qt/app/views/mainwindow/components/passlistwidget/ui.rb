class MainWindowPassListWidget < RubyQt6::Bando::QWidget
  private

  def initialize_ui
    initialize_combobox
    initialize_searchbar
    initialize_treewidget
    initialize_layout

    update_combobox_using_settings_stores
  end

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
    @searchbar.set_clear_button_enabled(true)
    @searchbar.set_placeholder_text("List passwords that match passname...")
    @searchbar.text_changed.connect(self, :_on_searchbar_text_changed)
  end

  def initialize_treewidget
    @treewidget = TreeWidget.new
    @treewidget.set_header_hidden(true)
    @treewidget.nil_selected.connect(self, :nil_selected)
    @treewidget.passfile_selected.connect(self, :passfile_selected)
    @treewidget.passfolder_selected.connect(self, :passfolder_selected)
  end

  def initialize_layout
    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_layout(@comboboxlayout)
    mainlayout.add_widget(@searchbar)
    mainlayout.add_widget(@treewidget)
  end

  def update_combobox_using_settings_stores
    PassQt.settings.GET_stores.each do |store|
      fileinfo = QFileInfo.new(store["fullpath"])
      @combobox.add_item(fileinfo.file_name, QVariant.new(fileinfo.absolute_file_path))
    end
  end
end
