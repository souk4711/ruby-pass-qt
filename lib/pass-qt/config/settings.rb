module PassQt
  class Settings
    def GET_mainwindow_geometry_and_restore_to(mainwindow)
      settings = QSettings.new
      mainwindow.restore_geometry(settings.value("MainWindow/geometry", QByteArray.new("")))
      mainwindow.restore_state(settings.value("MainWindow/windowState", QByteArray.new("")))
    end

    def PUT_mainwindow_geometry(mainwindow)
      settings = QSettings.new
      settings.set_value("MainWindow/geometry", mainwindow.save_geometry)
      settings.set_value("MainWindow/windowState", mainwindow.save_state)
    end

    def GET_stores
      settings = QSettings.new
      qstringlist = settings.value("Store/used", QStringList.new)
      if qstringlist.empty?
        default_stores.tap { |stores| PUT_stores(stores) }
      else
        qstringlist.map { |qstring| JSON.parse(qstring) }
      end
    end

    def PUT_stores(stores)
      settings = QSettings.new
      settings.set_value("Store/used", QStringList.new.tap do |qstringlist|
        stores.each { |store| qstringlist << store.to_json }
      end)
    end

    private

    def default_stores
      [] << {
        "fullpath" => QDir.home.file_path(".password-store")
      }
    end
  end
end
