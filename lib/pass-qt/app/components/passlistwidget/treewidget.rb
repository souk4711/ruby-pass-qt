require_relative "treewidget/helpers"
require_relative "treewidget/treebuilder"
require_relative "treewidget/treefilter"

class PassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
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
      menu = QMenu.new("", self)
      menu.set_attribute(Qt::WA_DeleteOnClose)

      menu.add_action(@new_password_action)
      menu.add_action(@new_otp_action)
      menu.add_action(@delete_action)

      menu.add_separator
      menu.add_action(@refresh_action)
      menu.add_action(@open_action)

      enabled = !selected_items.empty?
      @delete_action.set_enabled(enabled)

      menu.exec(evt.global_pos)
    end

    def refresh(store, selected_passname: nil)
      @store = store
      @dataitems = {}

      builder = TreeBuilder.new
      builder.perform(self, @store, @dataitems)

      expand_all
      @dataitems.each do |_, item|
        if item.passname == selected_passname
          set_current_item(item.treewidgetitem)
          break
        end
      end
    end

    def update_passname_filter(text)
      filter = TreeFilter.new
      filter.perform(self, @dataitems, text)
    end

    private

    def initialize_actions
      @new_password_action = initialize_actions_act(QIcon::ThemeIcon::DocumentNew, "New Password", :_on_new_password_action_triggered)
      @new_otp_action = initialize_actions_act(QIcon::ThemeIcon::DocumentNew, "New OTP", :_on_new_otp_action_triggered)
      @delete_action = initialize_actions_act(QIcon::ThemeIcon::EditDelete, "Delete", :_on_delete_action_triggered)
      @refresh_action = initialize_actions_act(QIcon::ThemeIcon::ViewRefresh, "Refresh", :_on_refresh_action_triggered)
      @open_action = initialize_actions_act(QIcon::ThemeIcon::FolderVisiting, "Open Store With File Explorer", :_on_open_action_triggered)
    end

    def initialize_actions_act(icon, text, slot)
      action = QAction.new(QIcon.from_theme(icon), text, self)
      action.triggered.connect(self, slot)
      action
    end

    def _on_current_item_changed(curr, _prev)
      if curr.nil?
        nil_selected.emit(@store)
        return
      end

      filepath = curr.data(1, Qt::DisplayRole).value
      dataitem = @dataitems[filepath]
      Helpers.passfile?(filepath) ?
        passfile_selected.emit(@store, dataitem.passname) :
        passfolder_selected.emit(@store, dataitem.passname)
    end

    def _on_new_password_action_triggered
      item = selected_items[0]
      if item
        filepath = item.data(1, Qt::DisplayRole).value
        folder = Helpers.folderpath(@store, QFileInfo.new(filepath))
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
        folder = Helpers.folderpath(@store, QFileInfo.new(filepath))
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
