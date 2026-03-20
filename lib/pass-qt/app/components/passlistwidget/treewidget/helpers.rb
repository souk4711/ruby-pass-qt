class PassListWidget < RubyQt6::Bando::QWidget
  class TreeWidget < RubyQt6::Bando::QTreeWidget
    module Helpers
      def self.passfile?(fileinfo)
        case fileinfo
        when QFileInfo then fileinfo.suffix.downcase == "gpg"
        when QString then fileinfo.ends_with(".gpg", Qt::CaseInsensitive)
        else raise "unreachable!"
        end
      end

      def self.folderpath(store, fileinfo)
        folder = fileinfo.dir? ? fileinfo.absolute_file_path : fileinfo.absolute_path
        QDir.new(store).relative_file_path(folder)
      end
    end
  end
end
