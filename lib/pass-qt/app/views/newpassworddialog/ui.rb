class NewPasswordDialog < RubyQt6::Bando::QDialog
  private

  def initialize_ui
    initialize_form
    initialize_btngroup
    initialize_layout

    set_attribute(Qt::WA_DeleteOnClose)
    set_modal(true)
  end

  def initialize_form
    titlelabel = QLabel.new("<center><b>Insert New Password</b></center>")

    @errinfolabel = QLabel.new("")
    @errinfolabel.set_style_sheet("background: white; color: red; padding: 8px; margin: 4px;")
    @errinfolabel.set_hidden(true)

    placeholder = (@folder == "") ? "example.com" : "#{@folder}/example.com"
    @passnamelabel = initialize_form_label("File")
    @passnameinput = initialize_form_inputfield(placeholder)
    @passnameinput.set_text(placeholder)
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
    @btngroup = QDialogButtonBox.new(QDialogButtonBox::Ok | QDialogButtonBox::Cancel, Qt::Horizontal)
    @btngroup.accepted.connect(self, :_on_okbutton_clicked)
    @btngroup.rejected.connect(self, :_on_cancelbutton_clicked)

    okbutton = @btngroup.button(QDialogButtonBox::Ok)
    okbutton.set_text("Create")
    okbutton.set_default(true)
    okbutton.set_auto_default(true)

    cancelbutton = @btngroup.button(QDialogButtonBox::Cancel)
    cancelbutton.set_auto_default(true)
  end

  def initialize_layout
    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_widget(@form)
    mainlayout.add_widget(@btngroup)
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
end
