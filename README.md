# **PROYECTO DAM**
Guía git

## 1. **Agregar Archivos al Área de Preparación**
```
git add .
```
## 2. **Hacer un Commit de los Cambios**
EJ: git commit -m **"08/01/2025 - 16:37"** -m "Problema de librerías solucionado"
```
git commit -m "fecha - hora:minutos" -m "descripción_detallada"
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
## **Deshacer un commit subido por error o falta algo**
Hice un commit lo subí a github y se me olvidó cambiar algo, ¿Como puedo deshacerlo y subir un solo commit?
```
git reset --soft HEAD~1
git push origin main --force
```
Realizar los cambios oportunos y seguir de nuevo los primeros 3 pasos.