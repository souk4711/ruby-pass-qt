QApplication.set_organization_name("souk4711")
QApplication.set_application_name("PassQt")

root_path = File.expand_path("../..", __dir__)
QDir.add_search_path("assets", File.join(root_path, "app/assets"))

icon = QIcon.from_theme("enpass")
QApplication.set_window_icon(icon)
