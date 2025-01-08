## **PROYECTO DAM**
Guía git

## 1. **Agregar Archivos al Área de Preparación**
```
git add .
```
## 2. **Hacer un Commit de los Cambios**
En el parámetro [-m **"update"**], es mejor poner algo **DESCRIPTIVO** o la **FECHA** de modificación y la **HORA**.  
EJ: git commit -m **"08/01/2025 - 16:37"**
```
git commit -m "update"
```
## 3. **Subir los Cambios al Repositorio Remoto**
Finalmente, si deseas subir los cambios a un repositorio remoto
```
git push origin main
```
## **Cargar los cambios del repositorio en el IDE**
Y cuando mis archivos en mi IDE están desactualizados sin los últimos cámbios, ¿Que hago?
```
git pull origin main
```
## **Volver a un commit anterior por algún error**
```
git reset --hard HEAD~1
git push origin main --force
```
