module PassQt
  class PassInfoWidget < RubyQt6::Bando::QWidget
    q_object do
      slot "_on_copy_action_triggered()"
      slot "_on_copy_action_triggered_otpcode()"
      slot "_on_view_action_triggered()"
    end

    def initialize
      super

      @store = QString.new
      @passname = QString.new

      initialize_form
      initialize_otpform
      initialize_folderform
      initialize_infoframe

      @stackedlayout = QStackedLayout.new
      @stackedlayout.add_widget(@form)
      @stackedlayout.add_widget(@otpform)
      @stackedlayout.add_widget(@folderform)
      @stackedlayout.add_widget(@infoframe)

      mainlayout = QVBoxLayout.new(self)
      mainlayout.add_spacing(76)
      mainlayout.add_layout(@stackedlayout)

      use_outinfolabel("")
    end

    def reinitialize_passfile(store, passname)
      @store = store
      @passname = passname
      use_outinfolabel("")

      Pass.show(@store, @passname, on_success: ->(data) {
        formdata = h_parse_passfile(data)
        if formdata["password"].start_with?("otpauth:")
          use_otpform(formdata)
        else
          use_form(formdata)
        end
      }, on_failure: ->(data) {
        errinfo = data["stderr"]
        use_errinfolabel(errinfo)
      })
    end

    def reinitialize_passfolder(store, passname)
      @store = store
      @passname = passname
      use_outinfolabel("")

      use_folderform
    end

    private

    def initialize_form
      @passnameinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@passnameinput)

      @passwordinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@passwordinput)
      initialize_form_inputfield_viewaction(@passwordinput)

      @usernameinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@usernameinput)

      @websiteinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@websiteinput)

      @form = QWidget.new
      formlayout = QFormLayout.new(@form)
      formlayout.add_row(initialize_form_label("File"), @passnameinput)
      formlayout.add_row(initialize_form_label("Username"), @usernameinput)
      formlayout.add_row(initialize_form_label("Password"), @passwordinput)
      formlayout.add_row(initialize_form_label("Website"), @websiteinput)
    end

    def initialize_otpform
      @otppassnameinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@otppassnameinput)

      @otppasswordinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@otppasswordinput)
      initialize_form_inputfield_viewaction(@otppasswordinput)

      @otpcodeinput = initialize_form_inputfield
      action = @otpcodeinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered_otpcode)

      @otpform = QWidget.new
      otpformlayout = QFormLayout.new(@otpform)
      otpformlayout.add_row(initialize_form_label("File"), @otppassnameinput)
      otpformlayout.add_row(initialize_form_label("OTP URI"), @otppasswordinput)
      otpformlayout.add_row(initialize_form_label("OTP Code"), @otpcodeinput)
    end

    def initialize_folderform
      @folderpassnameinput = initialize_form_inputfield
      initialize_form_inputfield_copyaction(@folderpassnameinput)

      @folderform = QWidget.new
      folderformlayout = QFormLayout.new(@folderform)
      folderformlayout.add_row(initialize_form_label("Folder"), @folderpassnameinput)
    end

    def initialize_form_label(text)
      label = QLabel.new(text)
      label.set_alignment(Qt::AlignRight)
      label.set_style_sheet("min-width: 80px; padding-right: 4px;")
      label
    end

    def initialize_form_inputfield
      input = QLineEdit.new
      input.set_read_only(true)
      input.set_focus_policy(Qt::NoFocus)
      input
    end

    def initialize_form_inputfield_copyaction(input)
      action = input.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered)
    end

    def initialize_form_inputfield_viewaction(input)
      action = input.add_action(QIcon.from_theme(QIcon::ThemeIcon::DocumentPrintPreview), QLineEdit::TrailingPosition)
      action.triggered.connect(self, :_on_view_action_triggered)
    end

    def initialize_infoframe
      @outinfolabel = QLabel.new
      @outinfolabel.set_style_sheet("color: black;")

      @errinfolabel = QLabel.new
      @errinfolabel.set_style_sheet("color: red;")

      @infoframe = QWidget.new
      infoframelayout = QVBoxLayout.new(@infoframe)
      infoframelayout.add_widget(@outinfolabel)
      infoframelayout.add_widget(@errinfolabel)
      infoframelayout.add_stretch
    end

    def use_form(formdata)
      @passnameinput.set_text(@passname)
      @passwordinput.set_text(formdata["password"])
      @passwordinput.set_echo_mode(QLineEdit::Password)

      @usernameinput.set_text(formdata["username"])
      @websiteinput.set_text(formdata["website"])
      @stackedlayout.set_current_widget(@form)
    end

    def use_otpform(formdata)
      @otppassnameinput.set_text(@passname)
      @otppasswordinput.set_text(formdata["password"])
      @otppasswordinput.set_cursor_position(0)
      @otppasswordinput.set_echo_mode(QLineEdit::Password)

      @otpcodeinput.set_text("")
      @stackedlayout.set_current_widget(@otpform)

      Pass.otp(@store, @passname, on_success: ->(data) {
        otpcode = data["stdout"].rstrip
        @otpcodeinput.set_text(otpcode)
      }, on_failure: ->(_) {})
    end

    def use_folderform
      @folderpassnameinput.set_text(@passname)
      @stackedlayout.set_current_widget(@folderform)
    end

    def use_outinfolabel(info)
      @errinfolabel.set_hidden(true)

      @outinfolabel.set_text(info)
      @outinfolabel.set_hidden(false)
      @stackedlayout.set_current_widget(@infoframe)
    end

    def use_errinfolabel(info)
      @outinfolabel.set_hidden(true)

      @errinfolabel.set_text(info)
      @errinfolabel.set_hidden(false)
      @stackedlayout.set_current_widget(@infoframe)
    end

    def h_parse_passfile(data)
      lines = data["stdout"].lines
      password = lines[0][..-2]

      username = ""
      website = ""
      lines.each do |line|
        matched = line.match(/\A(\w+:\s*)?(.*)\n/)
        next if matched.nil?

        case matched[1]&.rstrip&.downcase
        when "username:" then username = matched[2]
        when "website:" then website = matched[2]
        end
      end

      {
        "password" => password,
        "username" => username,
        "website" => website
      }
    end

    def _on_copy_action_triggered
      input = sender.parent
      QApplication.clipboard.set_text(input.text)
    end

    def _on_copy_action_triggered_otpcode
      Pass.otp(@store, @passname, on_success: ->(data) {
        otpcode = data["stdout"].rstrip
        @otpcodeinput.set_text(otpcode)
        QApplication.clipboard.set_text(otpcode)
      }, on_failure: ->(_) {})
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
