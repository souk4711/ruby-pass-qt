require_relative "newpassworddialog/ui"

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

    initialize_ui
  end

  private

  def _on_okbutton_clicked
    return unless _on_okbutton_clicked_validate_form

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

  def _on_okbutton_clicked_validate_form
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
