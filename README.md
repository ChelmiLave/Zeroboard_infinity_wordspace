# ZeroBoard V3

ZeroBoard es una aplicación Android para crear pizarras, presentaciones, documentos y notas. Esta entrega usa el editor de ZeroBoard 1.1 dentro de una aplicación Flutter.

## Archivos del proyecto

| Archivo o carpeta | Contenido |
| --- | --- |
| [`Aplicacion/`](Aplicacion/) | Código de la app Android y del editor, disponible archivo por archivo. |
| [`Servidor/`](Servidor/) | Código de la API y configuración de la base de datos. |
| [`COMPILAR_ZEROBOARD_V2.cmd`](COMPILAR_ZEROBOARD_V2.cmd) | Script de Windows para compilar la APK de prueba. |
| [`ZeroBoard-Guia.pdf`](ZeroBoard-Guia.pdf) | Documentación del proyecto. |

## Tecnologías

- **Flutter y Dart** inician la aplicación y se comunican con Android mediante un canal de plataforma.
- **Java y Android WebView** cargan el editor y gestionan el acceso a archivos desde Android. El editor está escrito en **HTML, CSS y JavaScript**.
- **Gradle 8.10.2 y Android SDK 35** compilan la app. El proyecto declara **Android 6.0 (API 23)** como mínimo.
- **C#, ASP.NET Core 10, Entity Framework Core y SQLite** componen la API. En esta entrega la app guarda sus datos localmente y la API se ejecuta por separado.

## Instalar en Android

1. Abre [Releases](https://github.com/ChelmiLave/Zeroboard_infinity_wordspace/releases/tag/zeroboard-v3-1e4e021) y descarga `ZeroBoard-1.1-Flutter.apk`.
2. Abre la APK desde el teléfono. Si Android lo solicita, autoriza la instalación desde la app con la que abriste el archivo. La APK disponible es una compilación de prueba.

## Compilar en Windows

1. Instala Flutter 3.32.4 (Dart 3.8.1), JDK 17, Android SDK 35 y NDK 28.2.13676358. Agrega Flutter al `PATH` y ejecuta `flutter doctor` para comprobar el entorno Android.
2. Clona el proyecto y abre su carpeta.

   ```powershell
   git clone https://github.com/ChelmiLave/Zeroboard_infinity_wordspace.git
   cd Zeroboard_infinity_wordspace
   ```

3. Ejecuta `COMPILAR_ZEROBOARD_V2.cmd` desde esa carpeta. Si termina correctamente, deja `ZeroBoard-1.1-Flutter.apk` en la raíz del proyecto.

## Ejecutar la API en local

Con el SDK de .NET 10 instalado, abre PowerShell en la raíz del proyecto.

```powershell
$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run --project Servidor --urls http://127.0.0.1:5080
```

Abre [`http://127.0.0.1:5080/health`](http://127.0.0.1:5080/health) para comprobar que responde. La API crea la base SQLite en `App_Data/zeroboard.db` de forma predeterminada.
