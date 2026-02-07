module PassQt
  class PassListWidget < RubyQt6::Bando::QWidget
    class TreeWidget < RubyQt6::Bando::QTreeWidget
      DataItem = Struct.new(:relativepath, :treewidgetitem)

      q_object do
      end

      def initialize
        super

        @store = QDir.new("")
        @dataitems = {}

        @fileiconprovider = QFileIconProvider.new
      end

      def update_store(store)
        @store = QDir.new(store)
        @dataitems = {}

        clear
        update_store_rebuild_tree(store)
      end

      def search(text)
      end

      private

      def update_store_rebuild_tree(store)
        dirs = [store]
        until dirs.empty?
          dir = dirs.pop
          diritem = @dataitems[dir]&.treewidgetitem || invisible_root_item

          entry_list = QDir.new(dir).entry_info_list(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)
          entry_list.each do |entry|
            fullpath = entry.absolute_file_path
            next if @dataitems.key?(fullpath)

            if entry.dir?
              dirs << fullpath
            elsif entry.file?
              next if entry.suffix != "gpg"
            else
              next
            end

            item = QTreeWidgetItem.new(diritem, QStringList.new << entry.complete_base_name)
            item.set_icon(0, @fileiconprovider.icon(entry))
            @dataitems[fullpath] = DataItem.new(@store.relative_file_path(fullpath), item)
          end
        end
      end
    end
  end
end
