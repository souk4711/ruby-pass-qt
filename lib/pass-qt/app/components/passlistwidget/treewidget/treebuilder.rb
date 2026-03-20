class PassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
    DataItem = Struct.new(:passname, :treewidgetitem)

    class TreeBuilder
      def initialize
        @fileiconprovider = QFileIconProvider.new
      end

      def perform(treewidget, store, dataitems)
        treewidget.clear

        store_root_path = QDir.new(store)
        dirs = [store]
        until dirs.empty?
          dir = dirs.shift
          diritem = dataitems[dir]&.treewidgetitem || treewidget.invisible_root_item

          entry_list = QDir.new(dir).entry_info_list(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)
          entry_list.each do |entry|
            next if entry.hidden?
            next if entry.file_name.starts_with(".")

            filepath = entry.absolute_file_path
            next if dataitems.key?(filepath)

            if entry.dir?
              dirs << filepath
              passname = store_root_path.relative_file_path(filepath)
            elsif entry.file?
              next unless Helpers.passfile?(entry)
              passname = store_root_path.relative_file_path(filepath)
              passname = passname[0, passname.size - entry.suffix.size - 1]
            else
              next
            end

            item = QTreeWidgetItem.new(diritem, QStringList.new << entry.complete_base_name << filepath)
            item.set_icon(0, @fileiconprovider.icon(entry))
            dataitems[filepath] = DataItem.new(passname, item)
          end
        end
      end
    end
  end
end
