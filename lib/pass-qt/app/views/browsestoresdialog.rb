require_relative "browsestoresdialog/ui"

class BrowseStoresDialog < RubyQt6::Bando::QDialog
  DataItem = Struct.new(:tablewidgetitem)

  q_object do
    signal "stores_changed()"
    slot "_on_list_add_button_clicked()"
    slot "_on_list_remove_button_clicked()"
  end

  def initialize
    super

    @dataitems = {}
    initialize_ui
  end

  private

  def _on_list_add_button_clicked
    dir = QFileDialog.get_existing_directory(self, "", QDir.home_path)
    return if dir.empty?

    if @dataitems.key?(dir)
      message = "<p>The following store already exists.</p>#{dir}"
      QMessageBox.critical(self, "", message)
      return
    end

    unless QDir.new(dir).exists(".gpg-id")
      message = "<p>The following store is invalid, because the .gpg-id file is missing.</p>#{dir}"
      QMessageBox.critical(self, "", message)
      return
    end

    update_tablewidget_addtableitem(dir)
  end

  def _on_list_remove_button_clicked
    update_tablewidget_removetableitem(sender.parent)
  end
end
