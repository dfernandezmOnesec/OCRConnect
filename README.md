# Función OCR con Python en Azure

Este repositorio demuestra un conjunto de recursos que permiten implementar una **Azure Function** en Python que utiliza **Tesseract OCR** para identificar páginas dentro de documentos PDF que contienen texto específico. Luego, esa página se extrae y se guarda como imagen JPEG en Azure Blob Storage.

Cuando se utiliza en conjunto con el proyecto [High Throughput Form Recognizer](https://github.com/mmckechney/HighThroughputFormRecognizer), permite realizar procesamiento de archivos y reconocimiento de formularios de forma **escalable y eficiente**, incluso para millones de documentos.

> **Nota:** Si planeas utilizar esta solución junto con el [High Throughput Form Recognizer](https://github.com/mmckechney/HighThroughputFormRecognizer), se recomienda ejecutar el script de despliegue de ambos repositorios usando los mismos valores para `appName`, `location` y `myPublicIp`, para asegurar su compatibilidad.

---

## Características

Esta solución utiliza los siguientes servicios de Azure:

- **Azure Blob Storage**, con dos contenedores:
  - `rawfile`: almacena los documentos PDF originales de múltiples páginas.
  - `incoming`: almacena las imágenes JPEG generadas (una por página relevante). Este nombre coincide con el contenedor esperado por el Form Recognizer.

- **Azure Service Bus**, con dos colas:
  - `rawqueue`: identifica los documentos PDF que requieren procesamiento.
  - `formqueue`: recibe los mensajes que activarán el reconocimiento posterior en el Form Recognizer.

- **Azure Functions**:
  - `PythonAIFunction`: función contenedorizada que escucha en la cola `rawqueue`, procesa el PDF, realiza el OCR con Tesseract y guarda la página como imagen JPEG.

- **Azure Container Registry**:
  - Repositorio desde el cual se despliega la función como contenedor Docker.

---

## Configuración

La solución utiliza **Azure Managed Identity** para conectarse de forma segura a Storage y enviar mensajes al Service Bus. Esta identidad requiere:

- Rol `Storage Blob Data Contributor` para la cuenta de almacenamiento.
- Rol `Azure Service Bus Data Owner` para el Service Bus.

### Variables de entorno necesarias (App Settings)

- `KEYWORD_LIST`: lista de palabras clave separadas por comas. La coincidencia distingue mayúsculas y minúsculas.
- `SERVICEBUS_CONNECTION`: cadena de conexión al Service Bus.
- `STORAGE_ACCT_URL`: URL de la cuenta de almacenamiento.
- `SOURCE_CONTAINER_NAME`: nombre del contenedor donde están los PDFs.
- `DESTINATION_CONTAINER_NAME`: nombre del contenedor donde se guardan las imágenes generadas.

> El archivo `function.json` debe tener configurado el campo `queueName` con el nombre de la cola correspondiente del Service Bus.

---

## Primeros pasos

Para probar la solución de punta a punta necesitas:

- Una suscripción de Azure con permisos para crear recursos.
- Tu dirección IP pública ([ver aquí](https://www.bing.com/search?q=what+is+my+ip)).
- Tener instalada la [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

### Ejecución del script de despliegue

1. Inicia sesión en Azure CLI:

```powershell
az login
Ejecuta el comando de despliegue:

```powershell
.\deploy.ps1 -appName "<nombreApp>" -location "<regiónAzure>" -myPublicIp "<tu_ip_pública>"```
Esto creará todos los recursos necesarios para ejecutar la solución.

Reconstrucción de la imagen del contenedor
La imagen se construye y almacena automáticamente en Azure Container Registry como parte del despliegue. Si necesitas reconstruirla manualmente, usa este comando con Azure Container Registry Tasks:


```az acr build --registry "<nombre_registro>" --image "<nombre>:<tag>" --file ./DOCKERFILE . --no-logs```
Créditos
Este repositorio está basado en el trabajo original de mmckechney, adaptado para entornos de procesamiento OCR con Tesseract en Azure y ampliado para integrarse fácilmente en arquitecturas como VEA Connect.


