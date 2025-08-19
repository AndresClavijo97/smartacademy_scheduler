puts "Creando datos de prueba..."

User.create!(
  email: "andres@smartacademy.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Andrés",
  last_name: "Test",
  active: true,
  schoolpack_username: "1144200793",
  schoolpack_password: "Adaytoremember1*",
  preferences_attributes: {
    office: "Bello",
    course: "A1",
    schedule: {
      monday: [ "17:00", "21:00" ],
      tuesday: [ "17:00", "21:00" ],
      wednesday: [ "17:00", "21:00" ]

    }
  }
)

puts "✅ Usuario de prueba creado exitosamente"
