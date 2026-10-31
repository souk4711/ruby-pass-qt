require_relative "passinfowidget/helpers"
require_relative "passinfowidget/ui"

class MainWindowPassInfoWidget < RubyQt6::Bando::QWidget
  q_object do
    slot "activate_passfilecard(QString,QString)"
    slot "activate_passfoldercard(QString,QString)"
    slot "activate_infocard()"
    slot "_on_copy_action_triggered()"
    slot "_on_copy_action_triggered_otpcode()"
    slot "_on_view_action_triggered()"
  end

  def initialize
    super

    initialize_ui
    activate_infocard
  end

  private

  def activate_passfilecard(store, passname)
    @store = store
    @passname = passname
    activate_infoframe

    Pass.show(@store, @passname, on_success: ->(data) {
      formdata = hlpr_parse_passfile(data)
      if formdata["password"].start_with?("otpauth:")
        activate_otpform(formdata)
      else
        activate_form(formdata)
      end
    }, on_failure: ->(data) {
      errinfo = data["stderr"]
      activate_infoframe_err(errinfo)
    })
  end

  def activate_passfoldercard(store, passname)
    @store = store
    @passname = passname
    activate_infoframe
    activate_folderform
  end

  def activate_infocard
    @store = QString.new
    @passname = QString.new
    activate_infoframe
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
