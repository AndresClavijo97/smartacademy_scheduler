class LoginPage < ApplicationPage
  def login
    visit('https://schoolpack.smart.edu.co/idiomas/alumnos.aspx')
    
    fill_in('vUSUCOD', with: user.schoolpack_username)
    fill_in('vPASS', with: user.schoolpack_password)

    click_button('BUTTON1')
  end
end