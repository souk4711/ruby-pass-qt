module PassQt
  class PassListWidget < RubyQt6::Bando::QWidget
    class TreeWidget < RubyQt6::Bando::QTreeWidget
      DataItem = Struct.new(:passname, :treewidgetitem)

      q_object do
        signal "passfile_changed(QString,QString)"
        slot "_on_item_clicked(QTreeWidgetItem*,int)"
      end

      def initialize
        super

        @store = QDir.new("")
        @dataitems = {}

        @fileiconprovider = QFileIconProvider.new

        item_clicked.connect(self, :_on_item_clicked)
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

      def search_passfile(text)
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
        passfile_changed.emit(@store.absolute_path, dataitem.passname) if h_passfile?(filepath)
      end
    end
  end
end
