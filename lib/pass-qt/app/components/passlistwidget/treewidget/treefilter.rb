class PassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
    class TreeFilter
      def perform(treewidget, dataitems, text)
        treewidget.set_current_item(nil)

        if text.empty?
          dataitems.each do |_, item|
            item.treewidgetitem.set_hidden(false)
            item.treewidgetitem.set_selected(false)
          end
          return
        end

        re_options = QRegularExpression::UnanchoredWildcardConversion | QRegularExpression::NonPathWildcardConversion
        re = QRegularExpression.from_wildcard(text, nil, re_options)

        filepath_matched = Set.new
        filepath_matched_1st = nil
        dataitems.each do |filepath, item|
          has_match = re.match(item.passname).has_match
          next unless has_match

          if filepath_matched_1st.nil?
            filepath_matched_1st = filepath if Helpers.passfile?(filepath)
          end

          loop do
            filepath_matched << filepath
            filepath = QFileInfo.new(filepath).absolute_path
            break unless dataitems.key?(filepath)
          end
        end

        dataitems.each do |filepath, item|
          visible = filepath_matched.include?(filepath)
          item.treewidgetitem.set_hidden(!visible)

          selected = filepath_matched_1st == filepath
          item.treewidgetitem.set_selected(selected)
        end
      end
    end
  end
end
