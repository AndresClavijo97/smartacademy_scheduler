class LoginPage < ApplicationPage

  def initialize(user)
    @username = user.schoolpack_username
    @password = user.schoolpack_password
  end

  def login
    visit('https://schoolpack.smart.edu.co/idiomas/alumnos.aspx')
    
    fill_in('vUSUCOD', with: @username)
    fill_in('vPASS', with: @password)

    click_button('BUTTON1')
    
    # Cerrar modal informativo si aparece
    close_info_modal if info_modal_present?
  end

  private

  def info_modal_present?
    has_css?('#gxp0_cls', wait: 3)
  end

  def close_info_modal
    find_and_click('#gxp0_cls')
    
    # Esperar a que el modal se cierre completamente
    has_no_css?('.gx-popup', wait: 5)
  end
end