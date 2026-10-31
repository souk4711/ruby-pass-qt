class MainWindowPassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
    private

    def refresh_imp(store, selected_passname:)
      @store = store
      @dataitems = {}

      clear
      refresh_imp_rebuild_tree
      expand_all

      if selected_passname.nil?
        set_current_item(nil)
      else
        @dataitems.each do |_, item|
          next if item.passname != selected_passname
          set_current_item(item.treewidgetitem)
          break
        end
      end
    end

    def refresh_imp_rebuild_tree
      file_icon_provider = QFileIconProvider.new
      store_root_path = QDir.new(@store)
      dirs = [@store]
      until dirs.empty?
        dir = dirs.shift
        diritem = @dataitems[dir]&.treewidgetitem || invisible_root_item

        entry_list = QDir.new(dir).entry_info_list(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)
        entry_list.each do |entry|
          next if entry.hidden?
          next if entry.file_name.starts_with(".")

          filepath = entry.absolute_file_path
          next if @dataitems.key?(filepath)

          if entry.dir?
            dirs << filepath
            passname = store_root_path.relative_file_path(filepath)
          elsif entry.file?
            next unless hlpr_passfile?(entry)
            passname = store_root_path.relative_file_path(filepath)
            passname = passname[0, passname.size - entry.suffix.size - 1]
          else
            next
          end

          item = QTreeWidgetItem.new(diritem, QStringList.new << entry.complete_base_name << filepath)
          item.set_icon(0, file_icon_provider.icon(entry))
          @dataitems[filepath] = DataItem.new(passname, item)
        end
      end
    end
  end
end
