module PassQt
  class PassListWidget < RubyQt6::Bando::QWidget
    class TreeWidget < RubyQt6::Bando::QTreeWidget
      DataItem = Struct.new(:fullname, :fileinfo, :treewidgetitem)

      q_object do
      end

      def initialize
        super

        @store = QDir.new("")
        @dataitems = {}

        @fileiconprovider = QFileIconProvider.new
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
              fullname = @store.relative_file_path(filepath)
            elsif entry.file?
              next unless entry.suffix == "gpg"
              fullname = @store.relative_file_path(filepath)
              fullname = fullname[0, fullname.size - entry.suffix.size - 1]
            else
              next
            end

            item = QTreeWidgetItem.new(diritem, QStringList.new << entry.complete_base_name)
            item.set_icon(0, @fileiconprovider.icon(entry))
            @dataitems[filepath] = DataItem.new(fullname, entry.dup, item)
          end
        end
      end

      def search_file(text)
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
          has_match = re.match(item.fullname).has_match
          next unless has_match

          if filepath_matched_1st.nil?
            filepath_matched_1st = filepath if item.fileinfo.suffix == "gpg"
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
    end
  end
end
