module PassQt
  class NewPasswordDialog < RubyQt6::Bando::QDialog
    q_object do
      slot "_on_okbutton_clicked()"
      slot "_on_cancelbutton_clicked()"
      slot "_on_view_action_triggered()"
    end

    def initialize(store, folder, on_success:)
      super()

      @store = store
      @folder = folder
      @on_success = on_success

      initialize_form
      initialize_btngroup

      mainlayout = QVBoxLayout.new(self)
      mainlayout.add_widget(@form)
      mainlayout.add_widget(@btngroup)

      set_attribute(Qt::WA_DeleteOnClose)
      set_modal(true)
    end

    private

    def initialize_form
      titlelabel = QLabel.new("<center><b>Insert New Password</b></center>")

      @errinfolabel = QLabel.new("")
      @errinfolabel.set_style_sheet("background: white; color: red; padding: 8px; margin: 4px;")
      @errinfolabel.set_hidden(true)

      placeholder = (@folder == "") ? "github.com" : "#{@folder}/github.com"
      @passnamelabel = initialize_form_label("File")
      @passnameinput = initialize_form_inputfield(placeholder)
      set_focus_proxy(@passnameinput)

      @passwordlabel = initialize_form_label("Password")
      @passwordinput = initialize_form_inputfield("")
      initialize_form_inputfield_viewaction(@passwordinput)

      @passwordinput.set_echo_mode(QLineEdit::Password)
      Pass.pwgen(16, on_success: ->(data) {
        @passwordinput.set_text(data["stdout"].lines[0].strip)
      }, on_failure: ->(_) {})

      @usernamelabel = initialize_form_label("Username")
      @usernameinput = initialize_form_inputfield("johndoe")

      @websitelabel = initialize_form_label("Website")
      @websiteinput = initialize_form_inputfield("https://github.com/login")

      @form = QWidget.new
      @form.set_object_name("newpassworddialog_form")
      @form.set_style_sheet("
        #newpassworddialog_form {
          min-width: 600px;
        }
      ")

      layout = QGridLayout.new(@form)
      layout.add_widget(titlelabel, 0, 0, 1, 2)
      layout.set_row_minimum_height(1, 10)
      layout.add_widget(@errinfolabel, 2, 0, 1, 2)
      layout.add_widget(@passnamelabel, 3, 0)
      layout.add_widget(@passnameinput, 3, 1)
      layout.add_widget(@usernamelabel, 4, 0)
      layout.add_widget(@usernameinput, 4, 1)
      layout.add_widget(@passwordlabel, 5, 0)
      layout.add_widget(@passwordinput, 5, 1)
      layout.add_widget(@websitelabel, 6, 0)
      layout.add_widget(@websiteinput, 6, 1)
    end

    def initialize_form_label(text)
      label = QLabel.new(text)
      label.set_alignment(Qt::AlignRight)
      label.set_style_sheet("min-width: 80px; padding-right: 4px;")
      label
    end

    def initialize_form_inputfield(placeholder)
      input = QLineEdit.new
      input.set_placeholder_text(placeholder)
      input
    end

    def initialize_form_inputfield_viewaction(input)
      action = input.add_action(QIcon.from_theme(QIcon::ThemeIcon::DocumentPrintPreview), QLineEdit::TrailingPosition)
      action.triggered.connect(self, :_on_view_action_triggered)
    end

    def initialize_btngroup
      @okbutton = QPushButton.new("Create")
      @okbutton.clicked.connect(self, :_on_okbutton_clicked)

      @cancelbutton = QPushButton.new("Cancel")
      @cancelbutton.clicked.connect(self, :_on_cancelbutton_clicked)

      @btngroup = QWidget.new
      layout = QHBoxLayout.new(@btngroup)
      layout.add_stretch
      layout.add_widget(@okbutton)
      layout.add_widget(@cancelbutton)
    end

    def update_form_errinfo(info)
      if info.empty?
        @errinfolabel.set_text("")
        @errinfolabel.set_hidden(true)
        return
      end

      @errinfolabel.set_text(info)
      @errinfolabel.set_hidden(false)
    end

    def validate_form
      update_form_errinfo("")

      {
        "File" => @passnameinput,
        "Username" => @usernameinput,
        "Password" => @passwordinput,
        "Website" => @websiteinput
      }.each do |k, v|
        next unless v.text.empty?

        update_form_errinfo("#{k} can't be blank")
        return false
      end

      true
    end

    def _on_okbutton_clicked
      return unless validate_form

      store = @store
      passname = @passnameinput.text
      password = @passwordinput.text
      username = @usernameinput.text
      website = @websiteinput.text
      extra = "Username: #{username}\nWebsite: #{website}\n"
      Pass.insert(store, passname, password, extra, on_success: ->(_) {
        @on_success.call(passname)
        close
      }, on_failure: ->(data) {
        update_form_errinfo(data["stderr"].strip)
      })
    end

    def _on_cancelbutton_clicked
      close
    end

    def _on_view_action_triggered
      input = sender.parent
      case input.echo_mode
      when QLineEdit::Normal then input.set_echo_mode(QLineEdit::Password)
      when QLineEdit::Password then input.set_echo_mode(QLineEdit::Normal)
      else raise "unreachable!"
      end
    end
  end
end
