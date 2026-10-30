class MainWindowPassInfoWidget < RubyQt6::Bando::QWidget
  private

  def initialize_ui
    initialize_form
    initialize_otpform
    initialize_folderform
    initialize_infoframe
    initialize_layout
  end

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

    @otpaccountinput = initialize_form_inputfield
    initialize_form_inputfield_copyaction(@otpaccountinput)

    @otpcodeinput = initialize_form_inputfield
    action = @otpcodeinput.add_action(QIcon.from_theme(QIcon::ThemeIcon::EditCopy), QLineEdit::LeadingPosition)
    action.triggered.connect(self, :_on_copy_action_triggered_otpcode)

    @otpform = QWidget.new
    otpformlayout = QFormLayout.new(@otpform)
    otpformlayout.add_row(initialize_form_label("File"), @otppassnameinput)
    otpformlayout.add_row(initialize_form_label("OTP URI"), @otppasswordinput)
    otpformlayout.add_row(initialize_form_label("Account"), @otpaccountinput)
    otpformlayout.add_row(initialize_form_label("Code"), @otpcodeinput)
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
    @infolabel = QLabel.new
    @infoframe = QWidget.new
    infoframelayout = QVBoxLayout.new(@infoframe)
    infoframelayout.add_widget(@infolabel)
    infoframelayout.add_stretch
  end

  def initialize_layout
    @stackedlayout = QStackedLayout.new
    @stackedlayout.add_widget(@form)
    @stackedlayout.add_widget(@otpform)
    @stackedlayout.add_widget(@folderform)
    @stackedlayout.add_widget(@infoframe)

    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_spacing(76)
    mainlayout.add_layout(@stackedlayout)
  end

  def activate_form(formdata)
    @passnameinput.set_text(@passname)
    @passwordinput.set_text(formdata["password"])
    @passwordinput.set_echo_mode(QLineEdit::Password)

    @usernameinput.set_text(formdata["username"])
    @websiteinput.set_text(formdata["website"])
    @stackedlayout.set_current_widget(@form)
  end

  def activate_otpform(formdata)
    @otppassnameinput.set_text(@passname)
    @otppasswordinput.set_text(formdata["password"])
    @otppasswordinput.set_cursor_position(0)
    @otppasswordinput.set_echo_mode(QLineEdit::Password)

    label = QUrl.new(formdata["password"]).path.to_s[1..]
    account = label.split(":")[-1]
    @otpaccountinput.set_text(account)

    @otpcodeinput.set_text("")
    @stackedlayout.set_current_widget(@otpform)

    Pass.otp(@store, @passname, on_success: ->(data) {
      otpcode = data["stdout"].rstrip
      @otpcodeinput.set_text(otpcode)
    }, on_failure: ->(_) {})
  end

  def activate_folderform
    @folderpassnameinput.set_text(@passname)
    @stackedlayout.set_current_widget(@folderform)
  end

  def activate_infoframe(info = "")
    @infolabel.set_style_sheet("color: black;")
    @infolabel.set_text(info)
    @stackedlayout.set_current_widget(@infoframe)
  end

  def activate_infoframe_err(info)
    @infolabel.set_style_sheet("color: red;")
    @infolabel.set_text(info)
    @stackedlayout.set_current_widget(@infoframe)
  end
end
