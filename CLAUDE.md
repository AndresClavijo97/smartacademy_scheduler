# SmartAcademy - Sistema de Gestión de Cursos

## Reglas del Sistema

### Estructura de Cursos
- **Sin instructores**: El sistema no maneja instructores, es un sistema automatizado
- **Cursos A1**: Cada curso de nivel A1 tiene exactamente 60 lecciones
- **Duración de lecciones**: Cada lección dura 1 hora y 30 minutos (90 minutos)

### Sistema de Horarios
- **Horario disponible**: 6:00 AM hasta 7:30 PM
- **Capacidad diaria**: Máximo 10 clases por día
- **Ejemplo de horario**:
  - Primera clase: 6:00 AM - 7:30 AM
  - Segunda clase: 7:30 AM - 9:00 AM
  - ... y así sucesivamente hasta 7:30 PM

### Convenciones de Código
- **Valores hardcoded**: Usar constantes de Ruby en lugar de números mágicos
- **Estructura MongoDB**: Usar Mongoid para todos los modelos
- **Validaciones**: Incluir validaciones apropiadas en todos los modelos
- **Relaciones**: Definir claramente las relaciones entre modelos
- **Nombres de clases**: Evitar prefijos redundantes como "SmartAcademy" en clases - usar nombres concisos
- **Value Objects**: Preferir value objects en lugar de hashes para estructuras de datos
- **Constantes**: Preferir constantes en lugar de métodos con códigos hardcodeados
- **Testing**: EVITAR crear archivos de ejemplo - usar pruebas unitarias (RSpec) para validar funcionalidad
- **Documentación**: Los specs sirven como documentación ejecutable del comportamiento esperado

### Modelos Principales
1. **User**: Usuarios del sistema (estudiantes)
2. **Course**: Cursos disponibles (principalmente A1)
3. **Lesson**: Lecciones individuales con horarios asignados
4. **Enrollment**: Inscripciones de usuarios en cursos

### Autenticación
- Usa Devise con campos personalizados:
  - first_name, last_name
  - schoolpack_username, schoolpack_password
- MongoDB como base de datos principal

### Integración SmartAcademia
- **Objetivo principal**: Conectar con SmartAcademia y registrar clases en cola
- **Credenciales**: Usar schoolpack_username y schoolpack_password del usuario
- **Sistema de cola**: Gestionar registros de clases pendientes
- **Sin interfaces iniciales**: Enfoque en backend y API integration
- **Flujo**: Usuario → Cola → Registro automático en SmartAcademia