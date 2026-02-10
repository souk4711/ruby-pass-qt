module PassQt
  class PassInfoWidget < RubyQt6::Bando::QWidget
    q_object do
      slot "_on_copy_action_triggered()"
      slot "_on_copy_action_triggered_otpcode()"
    end

    def initialize
      super

      @store = QString.new
      @passname = QString.new

      initialize_form
      initialize_otpform
      initialize_infoframe

      @stackedlayout = QStackedLayout.new
      @stackedlayout.add_widget(@form)
      @stackedlayout.add_widget(@otpform)
      @stackedlayout.add_widget(@infoframe)

      mainlayout = QVBoxLayout.new(self)
      mainlayout.add_spacing(76)
      mainlayout.add_layout(@stackedlayout)

      update_outinfolabel("")
    end

    def reinitialize_passfile(store, passname)
      @store = store
      @passname = passname

      Pass.show(@store, @passname, on_success: ->(data) {
        formdata = h_parse_passfile(data)
        if formdata["password"].start_with?("otpauth:")
          update_otpform(formdata)
        else
          update_form(formdata)
        end
      }, on_failure: ->(data) {
        errinfo = data["stderr"]
        update_errinfolabel(errinfo)
      })
    end

    private

    def initialize_form
      @usernameinput = initialize_form_inputfield
      action = @usernameinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered)

      @passwordinput = initialize_form_inputfield
      @passwordinput.set_echo_mode(QLineEdit::Password)
      action = @passwordinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered)

      @websiteinput = initialize_form_inputfield
      action = @websiteinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered)

      @form = QWidget.new
      formlayout = QFormLayout.new(@form)
      formlayout.add_row(QLabel.new("Username"), @usernameinput)
      formlayout.add_row(QLabel.new("Password"), @passwordinput)
      formlayout.add_row(QLabel.new("Website"), @websiteinput)
    end

    def initialize_otpform
      @otpinput = initialize_form_inputfield
      @otpinput.set_echo_mode(QLineEdit::Password)
      action = @otpinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered)

      @otpcodeinput = initialize_form_inputfield
      action = @otpcodeinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
      action.triggered.connect(self, :_on_copy_action_triggered_otpcode)

      @otpform = QWidget.new
      otpformlayout = QFormLayout.new(@otpform)
      otpformlayout.add_row(QLabel.new("OTP URI"), @otpinput)
      otpformlayout.add_row(QLabel.new("OTP Code"), @otpcodeinput)
    end

    def initialize_form_inputfield
      input = QLineEdit.new
      input.set_read_only(true)
      input.set_focus_policy(Qt::NoFocus)
      input
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

    def update_form(formdata)
      @usernameinput.set_text(formdata["username"])
      @passwordinput.set_text(formdata["password"])
      @websiteinput.set_text(formdata["website"])
      @stackedlayout.set_current_widget(@form)
    end

    def update_otpform(formdata)
      @otpinput.set_text(formdata["password"])
      @otpinput.set_cursor_position(0)
      @stackedlayout.set_current_widget(@otpform)

      Pass.otp(@store, @passname, on_success: ->(data) {
        otpcode = data["stdout"].rstrip
        @otpcodeinput.set_text(otpcode)
      }, on_failure: ->(_) {})
    end

    def update_outinfolabel(info)
      @errinfolabel.set_hidden(true)

      @outinfolabel.set_text(info)
      @outinfolabel.set_hidden(false)
      @stackedlayout.set_current_widget(@infoframe)
    end

    def update_errinfolabel(info)
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
  end
end
