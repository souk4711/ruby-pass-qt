class BrowseStoresDialog < RubyQt6::Bando::QDialog
  private

  def initialize_ui
    initialize_toolbar
    initialize_tablewidget
    initialize_layout

    set_attribute(Qt::WA_DeleteOnClose)
    set_modal(true)
  end

  def initialize_toolbar
    @toolbar = QWidget.new

    btn = QPushButton.new(QIcon.from_theme(QIcon::ThemeIcon::ListAdd), "Add")
    btn.clicked.connect(self, :_on_list_add_button_clicked)

    qhboxlayout = QHBoxLayout.new(@toolbar)
    qhboxlayout.add_widget(QLabel.new("Password Stores"))
    qhboxlayout.add_stretch
    qhboxlayout.add_widget(btn)
  end

  def initialize_tablewidget
    @tablewidget = QWidget.new
    @tablewidget.set_object_name("browsestoresdialog_tablewidget")
    @tablewidget.set_style_sheet("
      #browsestoresdialog_tablewidget {
        min-width: 600px;
        background: white;
      }
    ")

    QVBoxLayout.new(@tablewidget)
    PassQt.settings.GET_stores.each do |store|
      update_tablewidget_addtableitem(store["fullpath"])
    end
  end

  def initialize_layout
    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_stretch
    mainlayout.add_widget(@toolbar)
    mainlayout.add_widget(@tablewidget)
    mainlayout.add_stretch
  end

  def update_tablewidget_addtableitem(fullpath)
    tableitem = QWidget.new
    tableitemlayout = QHBoxLayout.new(tableitem)

    label = QLabel.new(fullpath)
    tableitemlayout.add_widget(label)
    tableitemlayout.add_stretch

    btn = QPushButton.new(QIcon.from_theme(QIcon::ThemeIcon::ListRemove), "Remove")
    btn.clicked.connect(self, :_on_list_remove_button_clicked)
    tableitemlayout.add_widget(btn)

    @dataitems[fullpath] = DataItem.new(tableitem)
    @tablewidget.layout.add_widget(tableitem)
    update_settings_stores
  end

  def update_tablewidget_removetableitem(tableitem)
    @dataitems.delete_if { |_, item| item.tablewidgetitem == tableitem }
    tableitem.delete_now
    update_settings_stores
  end

  def update_settings_stores
    stores = @dataitems.map { |fullpath, _| {"fullpath" => fullpath} }
    PassQt.settings.PUT_stores(stores)
    stores_changed.emit
  end
end
