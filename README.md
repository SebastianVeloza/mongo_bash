# Automatización de Instalación y Configuración de MongoDB

Este repositorio contiene un script en Bash diseñado para automatizar el proceso de instalación y configuración de MongoDB en sistemas operativos Linux. Esta herramienta simplifica el trabajo de instalación manual y asegura una configuración eficiente y estándar.

## Objetivo

El objetivo del script es realizar las siguientes tareas de forma automática:
- Instalar MongoDB desde los repositorios oficiales.
- Configurar los parámetros iniciales para el servicio de MongoDB.
- Iniciar y habilitar el servicio de MongoDB.
- Crear una estructura básica de bases de datos y usuarios, si se requiere.

## Funcionalidades

### Instalación de MongoDB
- Descarga la clave y el repositorio oficial de MongoDB.
- Actualiza los paquetes del sistema y procede con la instalación de MongoDB.

### Configuración del Servicio
- Habilita el servicio para que se ejecute automáticamente al iniciar el sistema.
- Inicia el servicio de MongoDB.

### Configuración de Bases de Datos y Usuarios (Opcional)
- Permite la creación de una base de datos predeterminada.
- Configura usuarios con roles específicos según las necesidades del proyecto.

### Ejecución
El script ejecuta automáticamente todos los comandos necesarios sin requerir intervención manual, asegurando consistencia y rapidez en la configuración.
