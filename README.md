# ServiTec

ServiTec es una aplicación móvil desarrollada con **Flutter y Firebase** para conectar clientes que necesitan servicios técnicos con técnicos que ofrecen dichos servicios.

La aplicación permite que un cliente publique una solicitud indicando el tipo de servicio requerido, una descripción del problema, ubicación, fotografías y un radio de búsqueda. Los técnicos pueden visualizar solicitudes cercanas relacionadas con sus categorías de trabajo, enviar cotizaciones y posteriormente gestionar los servicios contratados.

El proyecto fue desarrollado con fines académicos como parte del curso de Desarrollo de Software.

---

## Funcionalidades

### Cliente

- Registro e inicio de sesión.
- Recuperación y cambio de contraseña.
- Edición del perfil.
- Fotografía de perfil.
- Visualización de categorías de servicios.
- Creación de solicitudes de servicio.
- Registro de título, descripción y dirección.
- Obtención de ubicación mediante GPS.
- Configuración del radio de búsqueda.
- Carga de imágenes del problema.
- Visualización de solicitudes realizadas.
- Recepción de cotizaciones de técnicos.
- Visualización del perfil público del técnico.
- Aceptación de cotizaciones.
- Seguimiento del servicio contratado.
- Comunicación mediante chat con el técnico.
- Confirmación de finalización del servicio.
- Calificación y reseña del técnico.

### Técnico

- Registro e inicio de sesión.
- Edición del perfil profesional.
- Selección de categorías de servicio.
- Registro de años de experiencia.
- Configuración del radio de atención.
- Registro de ubicación.
- Fotografía de perfil.
- Visualización de solicitudes cercanas.
- Filtrado de solicitudes según categoría y distancia.
- Visualización del detalle de una solicitud.
- Envío de cotizaciones.
- Visualización de trabajos asignados.
- Inicio y finalización del servicio.
- Comunicación mediante chat con el cliente.
- Visualización de calificaciones y reseñas recibidas.

---

## Tecnologías utilizadas

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Geolocator
- Geocoding
- Image Picker
- Google Fonts

---

## Arquitectura general

La aplicación utiliza **Flutter** para la interfaz y la lógica de la aplicación móvil, mientras que **Firebase** proporciona los servicios de backend.

```text
                ServiTec
                   |
             Aplicación Flutter
                   |
        +----------+----------+
        |          |          |
        v          v          v
 Firebase Auth  Firestore  Firebase Storage
```

Firebase Authentication permite gestionar el acceso de clientes y técnicos.

Cloud Firestore almacena usuarios, perfiles, solicitudes, cotizaciones, servicios, conversaciones, mensajes y reseñas.

Firebase Storage almacena las fotografías de perfil y las imágenes asociadas a las solicitudes.

---

## Estructura del proyecto

La aplicación está organizada separando modelos, servicios, pantallas, utilidades, widgets y configuración visual.

```text
lib/
|
|-- models/
|   |-- app_user.dart
|   |-- category.dart
|   |-- chat_message.dart
|   |-- rating_summary.dart
|   |-- service_job.dart
|   |-- service_quote.dart
|   |-- service_request.dart
|   |-- service_review.dart
|   `-- technician_profile.dart
|
|-- screens/
|   |-- auth/
|   |-- chat/
|   |-- client/
|   |-- profile/
|   |-- quotes/
|   |-- requests/
|   |-- reviews/
|   |-- services/
|   `-- technician/
|
|-- services/
|   |-- auth_service.dart
|   |-- category_service.dart
|   |-- chat_service.dart
|   |-- location_service.dart
|   |-- quote_service.dart
|   |-- request_service.dart
|   |-- review_service.dart
|   |-- service_job_service.dart
|   |-- storage_service.dart
|   |-- technician_service.dart
|   `-- user_service.dart
|
|-- theme/
|-- utils/
|-- widgets/
|-- firebase_options.dart
`-- main.dart
```

---

## Base de datos

ServiTec utiliza **Cloud Firestore** como base de datos NoSQL.

Las principales colecciones utilizadas son:

```text
users
technician_profiles
categories
requests
services
conversations
reviews
```

Las solicitudes poseen una subcolección de cotizaciones:

```text
requests/{requestId}/quotes/{quoteId}
```

Las conversaciones poseen una subcolección de mensajes:

```text
conversations/{conversationId}/messages/{messageId}
```

### Organización general

```text
Usuario
   |
   +-- Cliente
   |     |
   |     +-- Solicitud
   |           |
   |           +-- Cotizaciones
   |
   +-- Técnico
         |
         +-- Perfil técnico

Solicitud
   |
   +-- Cotización aceptada
             |
             +-- Servicio
                    |
                    +-- Conversación
                    |       |
                    |       +-- Mensajes
                    |
                    +-- Reseña
```

---

## Almacenamiento de imágenes

Las imágenes utilizadas por la aplicación se almacenan mediante **Firebase Storage**.

Las fotografías de perfil utilizan una estructura similar a:

```text
profile_images/{userId}/profile.jpg
```

Las imágenes de solicitudes utilizan:

```text
requests/{clientId}/{requestId}/image_0.jpg
```

Una solicitud puede contener varias fotografías.

---

## Geolocalización y búsqueda de solicitudes

Los clientes pueden registrar la ubicación de la solicitud y establecer un radio de búsqueda para encontrar técnicos.

Los técnicos también registran su ubicación y configuran un radio de atención.

Para determinar qué solicitudes puede visualizar un técnico se consideran:

- categoría del servicio;
- ubicación del técnico;
- ubicación de la solicitud;
- radio de atención del técnico;
- radio de búsqueda definido por el cliente.

La distancia entre las coordenadas se calcula mediante las funcionalidades proporcionadas por el paquete `geolocator`.

---

## Flujo principal de la aplicación

```text
Cliente crea una solicitud
        |
        v
La solicitud queda disponible
        |
        v
Técnicos cercanos pueden visualizarla
        |
        v
Técnico envía una cotización
        |
        v
Cliente visualiza las cotizaciones
        |
        v
Cliente acepta una cotización
        |
        v
Se genera un servicio
        |
        v
Cliente y técnico pueden utilizar el chat
        |
        v
Técnico inicia el servicio
        |
        v
Técnico registra su finalización
        |
        v
Cliente confirma la finalización
        |
        v
Cliente puede calificar al técnico
```

---

## Estados del servicio

Durante el proceso de contratación el servicio puede pasar por diferentes estados.

```text
Pendiente de inicio
        |
        v
En progreso
        |
        v
Esperando confirmación del cliente
        |
        v
Completado
```

---

## Chat

Después de aceptar una cotización se crea una conversación asociada al servicio.

El cliente y el técnico pueden intercambiar mensajes utilizando una subcolección de mensajes en Cloud Firestore.

```text
conversations
      |
      +-- conversationId
              |
              +-- messages
                    |
                    +-- messageId
```

Cada mensaje almacena información como el usuario que lo envió, contenido y fecha de envío.

---

## Calificaciones y reseñas

Después de finalizar un servicio, el cliente puede registrar una calificación y una reseña sobre el técnico.

Estas calificaciones pueden visualizarse posteriormente en el perfil público del técnico.

---

## Autenticación

Firebase Authentication se utiliza para administrar el acceso de los usuarios.

La aplicación incorpora:

- registro de usuarios;
- inicio de sesión;
- cierre de sesión;
- recuperación de contraseña;
- cambio de contraseña.

Los usuarios tienen uno de los dos roles principales:

```text
Cliente
Técnico
```

---

## Seguridad

Firestore y Firebase Storage utilizan reglas de seguridad para controlar el acceso a la información.

Las operaciones requieren que el usuario esté autenticado y determinadas acciones están restringidas según el usuario relacionado con cada documento.

No deben almacenarse en el repositorio claves privadas, archivos de cuentas de servicio ni credenciales administrativas de Firebase.

---

## Requisitos para ejecutar el proyecto

Para ejecutar ServiTec es necesario tener instalado:

- Flutter SDK
- Dart SDK
- Android Studio o Visual Studio Code
- Android SDK
- Emulador Android o dispositivo físico
- Configuración de Firebase correspondiente al proyecto

Se puede comprobar la instalación de Flutter ejecutando:

```bash
flutter doctor
```

---

## Instalación

Clonar el repositorio:

```bash
git clone https://github.com/RubenDarioHuaylla/servitec-flutter.git
```

Entrar en la carpeta:

```bash
cd servitec-flutter
```

Instalar las dependencias:

```bash
flutter pub get
```

Ejecutar la aplicación:

```bash
flutter run
```

---

## Generar APK

Para generar un APK en modo release:

```bash
flutter build apk --release
```

El archivo se genera normalmente en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Estado del proyecto

Actualmente se encuentran implementadas las principales funcionalidades necesarias para completar el flujo de contratación de un servicio:

- autenticación;
- perfiles de clientes y técnicos;
- fotografías de perfil;
- solicitudes de servicio;
- imágenes de solicitudes;
- geolocalización;
- búsqueda de solicitudes cercanas;
- cotizaciones;
- contratación;
- seguimiento del servicio;
- chat;
- calificaciones y reseñas.

---

## Mejoras futuras

Como posibles mejoras futuras se consideran:

- notificaciones push;
- mejoras en el sistema de búsqueda;
- administración de usuarios y categorías;
- mayor control de permisos y roles;
- mejoras de interfaz y experiencia de usuario;
- optimización de consultas;
- publicación de la aplicación en una tienda de aplicaciones.

---

## Autor

**Rubén Darío Huaylla Peredo**

Estudiante de Ingeniería Informática y de Sistemas.

---

## Licencia

Proyecto desarrollado con fines académicos.
