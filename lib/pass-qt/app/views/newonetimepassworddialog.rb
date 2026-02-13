module PassQt
  class NewOneTimePasswordDialog < RubyQt6::Bando::QDialog
    q_object do
      slot "_on_okbutton_clicked()"
      slot "_on_cancelbutton_clicked()"
    end

    def initialize(store, folder)
      super()

      @store = store
      @folder = folder

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
      titlelabel = QLabel.new("<center><b>Insert New OTP Password</b></center>")

      @errinfolabel = QLabel.new("")
      @errinfolabel.set_style_sheet("background: white; color: red; padding: 8px; margin: 4px;")
      @errinfolabel.set_hidden(true)

      placeholder = (@folder == "") ? "github.com-otp" : "#{@folder}/github.com-otp"
      @passnamelabel = initialize_form_label("File")
      @passnameinput = initialize_form_inputfield(placeholder)
      set_focus_proxy(@passnameinput)

      @passwordlabel = initialize_form_label("OTP URI")
      @passwordinput = initialize_form_inputfield("otpauth://totp/GitHub...")

      @form = QWidget.new
      @form.set_object_name("newonetimepassworddialog_form")
      @form.set_style_sheet("
        #newonetimepassworddialog_form {
          min-width: 600px;
        }
      ")

      layout = QGridLayout.new(@form)
      layout.add_widget(titlelabel, 0, 0, 1, 2)
      layout.set_row_minimum_height(1, 10)
      layout.add_widget(@errinfolabel, 2, 0, 1, 2)
      layout.add_widget(@passnamelabel, 3, 0)
      layout.add_widget(@passnameinput, 3, 1)
      layout.add_widget(@passwordlabel, 4, 0)
      layout.add_widget(@passwordinput, 4, 1)
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

    def _on_okbutton_clicked
      store = @store
      passname = @passnameinput.text
      password = @passwordinput.text
      @errinfolabel.set_text("")
      @errinfolabel.set_hidden(true)

      Pass.otp_insert(store, passname, password, on_success: ->(data) {
        close
      }, on_failure: ->(data) {
        @errinfolabel.set_text(data["stderr"].strip)
        @errinfolabel.set_hidden(false)
      })
    end

    def _on_cancelbutton_clicked
      close
    end
  end
end
