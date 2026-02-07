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
        clear

        @store = QDir.new(store)
        @dataitems = {}

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

      def search(text)
        re_options = QRegularExpression::UnanchoredWildcardConversion | QRegularExpression::NonPathWildcardConversion
        re = QRegularExpression.from_wildcard(text, nil, re_options)

        visible_set = Set.new
        @dataitems.each do |fullpath, item|
          has_match = re.match(item.relativepath).has_match
          next unless has_match

          loop do
            visible_set << fullpath
            fullpath = QFileInfo.new(fullpath).absolute_path
            break unless @dataitems.key?(fullpath)
          end
        end

        @dataitems.each do |fullpath, item|
          hidden = !visible_set.include?(fullpath)
          item.treewidgetitem.set_hidden(hidden)
        end
      end
    end
  end
end
