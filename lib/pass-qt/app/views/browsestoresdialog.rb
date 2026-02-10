module PassQt
  class BrowseStoresDialog < RubyQt6::Bando::QDialog
    DataItem = Struct.new(:tablewidgetitem)

    q_object do
      slot "_on_list_add_button_clicked()"
      slot "_on_list_remove_button_clicked()"
    end

    def initialize
      super

      @dataitems = {}

      initialize_toolbar
      initialize_tablewidget

      mainlayout = QVBoxLayout.new(self)
      mainlayout.add_stretch
      mainlayout.add_widget(@toolbar)
      mainlayout.add_widget(@tablewidget)
      mainlayout.add_stretch

      set_attribute(Qt::WA_DeleteOnClose)
      set_modal(true)
    end

    private

    def initialize_toolbar
      @toolbar = QWidget.new

      btn = QPushButton.new(QIcon.from_theme(QIcon::ThemeIcon::ListAdd), "")
      btn.set_style_sheet("min-width: 32px; max-width: 32px;")
      btn.clicked.connect(self, :_on_list_add_button_clicked)

      qhboxlayout = QHBoxLayout.new(@toolbar)
      qhboxlayout.add_stretch
      qhboxlayout.add_widget(btn)
    end

    def initialize_tablewidget
      @tablewidget = QWidget.new
      @tablewidget.set_object_name("TableWidget")
      @tablewidget.set_style_sheet("
        QWidget#TableWidget {
          min-width: 600px;
          background: white;
        }
      ")

      QVBoxLayout.new(@tablewidget)
      PassQt.settings.GET_stores.each do |store|
        update_tablewidget_addtableitem(store["fullpath"])
      end
    end

    private

    def update_tablewidget_addtableitem(fullpath)
      tableitem = QWidget.new
      tableitemlayout = QHBoxLayout.new(tableitem)

      label = QLabel.new(fullpath)
      tableitemlayout.add_widget(label)

      btn = QPushButton.new(QIcon.from_theme(QIcon::ThemeIcon::ListRemove), "")
      btn.set_style_sheet("min-width: 32px; max-width: 32px;")
      btn.clicked.connect(self, :_on_list_remove_button_clicked)
      tableitemlayout.add_widget(btn)

      @tablewidget.layout.add_widget(tableitem)
      @dataitems[fullpath] = DataItem.new(tableitem)
    end

    def update_tablewidget_removetableitem(tableitem)
      tableitem.delete_now
      @dataitems.delete_if { |_, item| item.tablewidgetitem == tableitem }
    end

    def h_put_stores
      stores = @dataitems.map { |fullpath, _| {"fullpath" => fullpath} }
      PassQt.settings.PUT_stores(stores)
    end

    def _on_list_add_button_clicked
      dir = QFileDialog.get_existing_directory(self, "Select Store Folder", QDir.home_path)
      return if dir.empty?

      if @dataitems.key?(dir)
        message = "store `#{dir}` already exists."
        QMessageBox.critical(self, "", message)
        return
      end

      unless QDir.new(dir).exists(".gpg-id")
        message = "store `#{dir}` invalid, missing .gpg-id file."
        QMessageBox.critical(self, "", message)
        return
      end

      update_tablewidget_addtableitem(dir)
      h_put_stores
    end

    def _on_list_remove_button_clicked
      update_tablewidget_removetableitem(sender.parent)
      h_put_stores
    end
  end
end
