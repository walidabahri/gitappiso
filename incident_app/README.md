# Gestión de Incidencias - iOS App

Esta aplicación iOS forma parte del proyecto integrado para la gestión de incidencias de una empresa. Permite a los operarios visualizar, crear y gestionar incidencias asignadas a ellos.

## Características

- **Autenticación de usuarios**: Sistema de login seguro para operarios
- **Gestión de incidencias**: Visualización, creación y actualización de incidencias
- **Seguimiento de estado**: Actualización del estado de las incidencias (pendiente, en proceso, resuelta, cancelada)
- **Localización GPS**: Captura de ubicación para nuevas incidencias
- **Comentarios**: Sistema de comunicación mediante comentarios en incidencias
- **Interfaz adaptada por rol**: Visualización de información relevante según el rol del usuario

## Requisitos técnicos

- iOS 16.0 o superior
- Xcode 14.0 o superior
- Swift 5.7 o superior
- Conexión a internet para comunicación con la API backend

## Instalación y configuración

1. Clona el repositorio:
```
git clone https://github.com/walidabahri/gitappiso.git
```

2. Abre el proyecto en Xcode:
```
cd gitappiso/incident_app
open incident_app.xcodeproj
```

3. Configura la URL del backend:
   - Abre el archivo `APIService.swift` en la carpeta Services
   - Actualiza la variable `baseURL` con la URL de tu backend Django

4. Compila y ejecuta la aplicación en el simulador o dispositivo físico.

## Estructura del proyecto

```
incident_app/
├── Models/              # Modelos de datos
│   ├── User.swift       # Modelo de usuario
│   ├── Incident.swift   # Modelo de incidencia
│   ├── IncidentComment.swift # Modelo de comentarios
│   └── APIModels.swift  # Modelos para comunicación con la API
├── Services/            # Servicios y lógica de negocio
│   ├── APIService.swift # Servicio para comunicación con la API
│   ├── AuthService.swift # Servicio de autenticación
│   └── LocationService.swift # Servicio de localización GPS
├── ViewModels/          # ViewModels (MVVM)
│   ├── LoginViewModel.swift
│   ├── IncidentsViewModel.swift
│   └── CreateIncidentViewModel.swift
├── Views/               # Interfaces de usuario
│   ├── LoginView.swift
│   ├── IncidentsListView.swift
│   ├── CreateIncidentView.swift
│   ├── IncidentDetailView.swift
│   └── ProfileView.swift
└── ContentView.swift    # Vista principal y navegación
```

## Comunicación con el backend

La aplicación se comunica con una API REST desarrollada en Django. Los endpoints principales son:

- `/api/token/` - Autenticación y obtención de token
- `/api/incidents/` - Listado y creación de incidencias
- `/api/incidents/<id>/` - Detalle y actualización de incidencias
- `/api/incidents/<id>/comments/` - Comentarios de incidencias
- `/api/users/me/` - Información del usuario actual

## Seguridad

La aplicación utiliza JWT (JSON Web Tokens) para la autenticación, almacenados de forma segura en UserDefaults. Todas las peticiones a la API incluyen el token en las cabeceras HTTP.

## Personalización

Para personalizar la aplicación:

1. Modifica el archivo `Info.plist` para cambiar el nombre de la aplicación, identificador y permisos
2. Actualiza los colores y estilos en las vistas SwiftUI según tu marca corporativa
3. Ajusta la URL del backend en `APIService.swift`

## Contacto

Para cualquier consulta o soporte, contacta con:
- Email: [tu-email@ejemplo.com]
- GitHub: [https://github.com/walidabahri]
