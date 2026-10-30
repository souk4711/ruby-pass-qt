class MainWindowPassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
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

    def initialize_context_menu
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

      menu
    end
  end
end
