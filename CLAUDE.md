# SmartAcademy - Sistema de Gestión de Cursos

## Reglas del Sistema

### Estructura de Cursos (Confirmado por Screenshots Completos)
- **Sin instructores**: El sistema no maneja instructores, es un sistema automatizado
- **Estructura por nivel**: Cada nivel tiene 98 lecciones totales (82 obligatorias + 16 opcionales)
- **Lecciones obligatorias**: 8 INTRO + 72 CLASE + 2 EXAMEN (preparación + final)
- **Lecciones opcionales**: 8 QUIZ UNITS + 8 SMART ZONE distribuidos a lo largo del nivel
- **Duración de lecciones**: Cada lección dura 1 hora y 30 minutos (90 minutos)
- **Progresión automática**: Usuario avanza al siguiente nivel al completar las 82 lecciones obligatorias
- **Secuencia numérica**: Las clases siguen numeración secuencial del 1 al 98 (A1), 99-196 (A2), etc.
- **Transición de niveles**: A1 termina en clase 98, A2 comienza en clase 99

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

### Tipos de Lecciones (Estructura Real Confirmada por Screenshots)
- **INTRO (números 1-8)**: 8 clases introductorias obligatorias (90 min cada una)
- **CLASE (números 9-96)**: 72 clases principales obligatorias distribuidas en bloques (90 min cada una)
- **QUIZ UNITS**: 8 evaluaciones opcionales distribuidas a lo largo del nivel (90 min cada una)
- **SMART ZONE**: 8 actividades complementarias opcionales distribuidas (90 min cada una)
- **PREPARACIÓN EXAMEN FINAL (número 97)**: 1 clase preparatoria obligatoria (90 min)
- **EXAMEN FINAL (número 98)**: 1 evaluación final obligatoria (90 min)

### Estados de Lecciones
- **scheduled**: Programada pero no iniciada
- **in_progress**: En curso
- **completed**: Completada exitosamente
- **cancelled**: Cancelada
- **no_show**: Usuario no se presentó

### Modelos Principales
1. **User**: Usuarios del sistema (estudiantes)
2. **Course**: Cursos por nivel (A1, A2, B1, B2, C1)
3. **Lesson**: Lecciones individuales con horarios y estados
4. **LessonType**: Tipos de lecciones (regular, quiz, smart_zone, etc.)
5. **Enrollment**: Inscripciones de usuarios en cursos

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