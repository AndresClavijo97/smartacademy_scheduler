# SmartAcademy - Sistema de Gestión de Cursos

![CI](https://github.com/USERNAME/smartacademy/workflows/CI/badge.svg)
![Ruby Version](https://img.shields.io/badge/ruby-3.4.5-red.svg)
![Rails Version](https://img.shields.io/badge/rails-8.0.2-red.svg)
![MongoDB](https://img.shields.io/badge/mongodb-7.0-green.svg)

Sistema automatizado para la gestión de cursos de inglés con integración a SmartAcademia.

## 🚀 Características

- **Sistema de usuarios** con autenticación Devise
- **Gestión de lecciones** con state machine (AASM)
- **Base de datos MongoDB** con Mongoid ODM
- **Estructura de niveles** (A1, A2, B1) con 98 lecciones por nivel
- **Tipos de lecciones**: Intro, Clase, Quiz Units, Smart Zone, Exámenes
- **Cobertura de pruebas** del 31% con SimpleCov

## 🛠️ Tecnologías

- **Ruby** 3.4.5
- **Rails** 8.0.2
- **MongoDB** 7.0
- **Mongoid** ORM
- **Devise** para autenticación
- **AASM** para state machines
- **Tailwind CSS** para estilos
- **RSpec** para pruebas
- **SimpleCov** para cobertura de código

## 📋 Requisitos

- Ruby 3.4.5
- MongoDB 7.0+
- Node.js (para asset pipeline)

## 🔧 Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/USERNAME/smartacademy.git
   cd smartacademy
   ```

2. **Instalar dependencias**
   ```bash
   bundle install
   ```

3. **Configurar MongoDB**
   ```bash
   # Asegúrate de que MongoDB esté ejecutándose
   mongod
   ```

4. **Ejecutar la aplicación**
   ```bash
   bin/dev
   ```

## 🧪 Pruebas

### Ejecutar todas las pruebas
```bash
bundle exec rspec
```

### Ejecutar pruebas con cobertura
```bash
RAILS_ENV=test bundle exec rspec
```

### Ver reporte de cobertura
Abre `coverage/index.html` en tu navegador después de ejecutar las pruebas.

## 📊 Estado de las Pruebas

- **94 pruebas** ejecutándose correctamente
- **0 fallos**
- **Cobertura**: 31.23% (104/333 líneas)

### Tipos de pruebas incluidas:
- ✅ Validaciones de modelos
- ✅ Asociaciones entre modelos
- ✅ State machine con AASM
- ✅ Scopes y consultas
- ✅ Autenticación con Devise
- ✅ Request specs para controladores

## 🏗️ Estructura del Proyecto

```
app/
├── models/
│   ├── user.rb          # Usuarios del sistema
│   ├── lesson.rb        # Lecciones con state machine
│   └── preference.rb    # Preferencias de usuario
├── controllers/
│   ├── home_controller.rb
│   └── users/           # Controladores de Devise
└── services/
    └── users/           # Servicios para integración

spec/
├── models/              # Pruebas de modelos
├── requests/            # Pruebas de controladores
└── factories/           # Factory Bot para datos de prueba
```

## 🔄 CI/CD

El proyecto incluye GitHub Actions que ejecutan:

- **Análisis de seguridad** con Brakeman
- **Auditoría de dependencias** JavaScript
- **Linting** con RuboCop
- **Pruebas automatizadas** con RSpec
- **Reporte de cobertura** con SimpleCov

## 📈 Roadmap

- [ ] Aumentar cobertura de pruebas al 80%
- [ ] Agregar pruebas de integración
- [ ] Implementar servicios para SmartAcademia
- [ ] Agregar documentación API

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.
