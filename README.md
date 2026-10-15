# ZeroBoard · estructura y modelos (C# / .NET MAUI + SQLite)

## 1. Crear el proyecto
    dotnet workload install maui
    dotnet new maui -n ZeroBoard
    cd ZeroBoard

## 2. Paquetes NuGet
    dotnet add package sqlite-net-pcl
    dotnet add package SQLitePCLRaw.bundle_green
    dotnet add package CommunityToolkit.Mvvm
    dotnet add package SkiaSharp.Views.Maui.Controls     # lienzo y exportación PDF/PNG
    dotnet add package Plugin.LocalNotification          # recordatorios locales

## 3. Copiar
Copia las carpetas `Core`, `Data`, `CanvasEngine`, `Domain`, `UI`, `Docs` y `Resources/Raw/sql` dentro del proyecto.
En el .csproj los archivos de `Resources/Raw` ya se incluyen solos como MauiAsset.

## 4. Registrar servicios
Pega lo de `MauiProgram_registro.txt` en `MauiProgram.cs`.

## 5. Probar
Inyecta `ProyectoRepository` en un ViewModel y llama `await repo.CrearAsync("Prueba", TipoDiseno.Pizarra);`.
La base se crea sola la primera vez en `FileSystem.AppDataDirectory`.

## Notas
- `Resources/Raw/sql/schema.sql` es la fuente del esquema; `Data/Database/SchemaV1.cs` se generó de ahí.
- Enums = INTEGER, fechas = texto ISO 8601, booleanos = 0/1, colores = INTEGER ARGB.
- `schema_v2_sync.sql` (usuario/colaboración) NO se usa en la v1.
