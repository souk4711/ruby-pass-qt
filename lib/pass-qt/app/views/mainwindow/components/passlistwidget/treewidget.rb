require_relative "treewidget/funcs"
require_relative "treewidget/helpers"
require_relative "treewidget/ui"

class MainWindowPassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
    DataItem = Struct.new(:passname, :treewidgetitem)

    q_object do
      signal "nil_selected(QString)"
      signal "passfile_selected(QString,QString)"
      signal "passfolder_selected(QString,QString)"
      slot "_on_current_item_changed(QTreeWidgetItem*,QTreeWidgetItem*)"
      slot "_on_new_password_action_triggered()"
      slot "_on_new_otp_action_triggered()"
      slot "_on_delete_action_triggered()"
      slot "_on_refresh_action_triggered()"
      slot "_on_open_action_triggered()"
    end

    def initialize
      super

      @store = QString.new
      @dataitems = {}

      initialize_actions
      current_item_changed.connect(self, :_on_current_item_changed)
    end

    def context_menu_event(evt)
      menu = initialize_context_menu
      menu.exec(evt.global_pos)
    end

    def refresh(store, selected_passname: nil)
      refresh_imp(store, selected_passname:)
    end

    def filter(text)
      filter_imp(text)
    end

    private

    def _on_current_item_changed(curr, _prev)
      if curr.nil?
        nil_selected.emit(@store)
        return
      end

      filepath = curr.data(1, Qt::DisplayRole).value
      dataitem = @dataitems[filepath]
      hlpr_passfile?(filepath) ?
        passfile_selected.emit(@store, dataitem.passname) :
        passfolder_selected.emit(@store, dataitem.passname)
    end

    def _on_new_password_action_triggered
      item = selected_items[0]
      if item
        filepath = item.data(1, Qt::DisplayRole).value
        folder = hlpr_folderpath(@store, QFileInfo.new(filepath))
        folder = "" if folder == "."
      else
        folder = ""
      end

      dialog = NewPasswordDialog.new(@store, folder, on_success: ->(passname) {
        refresh(@store, selected_passname: passname)
      })
      dialog.show
    end

    def _on_new_otp_action_triggered
      item = selected_items[0]
      if item
        filepath = item.data(1, Qt::DisplayRole).value
        folder = hlpr_folderpath(@store, QFileInfo.new(filepath))
        folder = "" if folder == "."
      else
        folder = ""
      end

      dialog = NewOneTimePasswordDialog.new(@store, folder, on_success: ->(passname) {
        refresh(@store, selected_passname: passname)
      })
      dialog.show
    end

    def _on_delete_action_triggered
      item = selected_items[0]
      filepath = item.data(1, Qt::DisplayRole).value
      dataitem = @dataitems[filepath]

      message = "<p>Do you really want to delete this item?</p>#{dataitem.passname}"
      reply = QMessageBox.question(self, "", message)
      return if reply == QMessageBox::No

      file = QFile.new(filepath)
      file.move_to_trash
      refresh(@store)
    end

    def _on_refresh_action_triggered
      item = selected_items[0]
      if item
        filepath = item.data(1, Qt::DisplayRole).value
        dataitem = @dataitems[filepath]
        passname = dataitem.passname
      else
        passname = ""
      end

      refresh(@store, selected_passname: passname)
    end

    def _on_open_action_triggered
      url = QUrl.from_local_file(@store)
      QDesktopServices.open_url(url)
    end
  end
end
