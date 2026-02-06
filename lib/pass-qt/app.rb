require_relative "config"
require_relative "lib"

require_relative "app/views"

module PassQt
  class Application
    def self.run
      new.exec
    end

    def initialize
      @app = QApplication.new
      @mainwindow = MainWindow.new
    end

    def exec
      @mainwindow.show
      @app.exec
    end
  end
end
