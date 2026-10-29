require_relative "newonetimepassworddialog/ui"

class NewOneTimePasswordDialog < RubyQt6::Bando::QDialog
  q_object do
    slot "_on_okbutton_clicked()"
    slot "_on_cancelbutton_clicked()"
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
    Pass.otp_insert(store, passname, password, on_success: ->(_) {
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
      "OTP URI" => @passwordinput
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
end
