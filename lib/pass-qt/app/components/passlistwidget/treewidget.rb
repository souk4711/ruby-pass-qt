module PassQt
  class PassListWidget < RubyQt6::Bando::QWidget
    class TreeWidget < RubyQt6::Bando::QTreeWidget
      DataItem = Struct.new(:passname, :treewidgetitem)

      q_object do
        signal "passfile_selected(QString,QString)"
        signal "passfolder_selected(QString,QString)"
        slot "_on_item_clicked(QTreeWidgetItem*,int)"
        slot "_on_new_password_action_triggered()"
        slot "_on_new_otp_action_triggered()"
        slot "_on_delete_action_triggered()"
        slot "_on_refresh_action_triggered()"
        slot "_on_open_action_triggered()"
      end

      def initialize
        super

        @store = QDir.new("")
        @dataitems = {}

        initialize_actions
        initialize_fileiconprovider

        item_clicked.connect(self, :_on_item_clicked)
      end

      def context_menu_event(evt)
        menu = QMenu.new("", self)

        menu.add_action(@new_password_action)
        menu.add_action(@new_otp_action)
        menu.add_action(@delete_action)

        menu.add_separator
        menu.add_action(@refresh_action)
        menu.add_action(@open_action)

        menu.exec(evt.global_pos)
      end

      def reinitialize_store(store)
        clear

        @store = QDir.new(store)
        @dataitems = {}

        dirs = [store]
        until dirs.empty?
          dir = dirs.shift
          diritem = @dataitems[dir]&.treewidgetitem || invisible_root_item

          entry_list = QDir.new(dir).entry_info_list(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)
          entry_list.each do |entry|
            filepath = entry.absolute_file_path
            next if @dataitems.key?(filepath)

            if entry.dir?
              dirs << filepath
              passname = @store.relative_file_path(filepath)
            elsif entry.file?
              next unless h_passfile?(entry)
              passname = @store.relative_file_path(filepath)
              passname = passname[0, passname.size - entry.suffix.size - 1]
            else
              next
            end

            item = QTreeWidgetItem.new(diritem, QStringList.new << entry.complete_base_name << filepath)
            item.set_icon(0, @fileiconprovider.icon(entry))
            @dataitems[filepath] = DataItem.new(passname, item)
          end
        end
      end

      def update_passname_filter(text)
        if text.empty?
          @dataitems.each do |_, item|
            item.treewidgetitem.set_hidden(false)
            item.treewidgetitem.set_selected(false)
          end
          return
        end

        re_options = QRegularExpression::UnanchoredWildcardConversion | QRegularExpression::NonPathWildcardConversion
        re = QRegularExpression.from_wildcard(text, nil, re_options)

        filepath_matched = Set.new
        filepath_matched_1st = nil
        @dataitems.each do |filepath, item|
          has_match = re.match(item.passname).has_match
          next unless has_match

          if filepath_matched_1st.nil?
            filepath_matched_1st = filepath if h_passfile?(filepath)
          end

          loop do
            filepath_matched << filepath
            filepath = QFileInfo.new(filepath).absolute_path
            break unless @dataitems.key?(filepath)
          end
        end

        @dataitems.each do |filepath, item|
          visible = filepath_matched.include?(filepath)
          item.treewidgetitem.set_hidden(!visible)

          selected = filepath_matched_1st == filepath
          item.treewidgetitem.set_selected(selected)
        end
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

      def initialize_fileiconprovider
        @fileiconprovider = QFileIconProvider.new
      end

      def h_passfile?(fileinfo)
        case fileinfo
        when QFileInfo then fileinfo.suffix.downcase == "gpg"
        when QString then fileinfo.ends_with(".gpg", Qt::CaseInsensitive)
        else raise "unreachable!"
        end
      end

      def _on_item_clicked(item, _column)
        filepath = item.data(1, Qt::DisplayRole).value
        dataitem = @dataitems[filepath]
        h_passfile?(filepath) ?
          passfile_selected.emit(@store.absolute_path, dataitem.passname) :
          passfolder_selected.emit(@store.absolute_path, dataitem.passname)
      end

      def _on_new_password_action_triggered
      end

      def _on_new_otp_action_triggered
      end

      def _on_delete_action_triggered
      end

      def _on_refresh_action_triggered
      end

      def _on_open_action_triggered
        url = QUrl.from_local_file(@store.absolute_path)
        QDesktopServices.open_url(url)
      end
    end
  end
end
