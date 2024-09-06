# Planificador de Estudios Personalizado

Este es un proyecto en desarrollo que consiste en una página web creada con Flutter y Firebase para calcular planes de estudio personalizados para carreras universitarias. La plataforma está pensada para aquellos estudiantes que, por diferentes motivos, no pueden seguir el plan de estudios general proporcionado por su universidad.

## Descripción

El proyecto permite a los usuarios identificarse únicamente con su DNI y, basándose en las correlativas de las materias y la disponibilidad horaria ingresada, genera un plan de estudio personalizado. Está diseñado especialmente para:

- Estudiantes que han quedado rezagados en alguna materia.
- Estudiantes que trabajan o tienen otras actividades que les impiden seguir el plan de estudio tradicional.
- Aquellos que desean avanzar en su carrera a un ritmo diferente al estipulado por la universidad.

Actualmente, solo está cargada la carrera de **Licenciatura en Ciencias de la Computación (plan viejo)** de la Universidad Nacional de Río Cuarto. Sin embargo, el objetivo a largo plazo es incluir todas las carreras posibles de esta institución y, eventualmente, de otras instituciones.

## Estado del Proyecto

El proyecto aún está en construcción y se avanza en él en los tiempos disponibles. Todavía no está en un estado final y las funcionalidades pueden cambiar o ampliarse en el futuro.

## Instalación y Ejecución

Para probar el proyecto en su estado actual, es necesario:

1. Clonar este repositorio.
2. Instalar Flutter y configurar tu entorno siguiendo la [documentación oficial de Flutter](https://flutter.dev/docs/get-started/install).
3. Configurar Firebase en el proyecto, siguiendo las instrucciones proporcionadas en la [documentación de Firebase](https://firebase.google.com/docs/flutter/setup).
4. Ejecutar la aplicación en un simulador o dispositivo físico.

```bash
git clone https://github.com/tu-usuario/planificador-estudios.git
cd planificador-estudios
flutter pub get
flutter run
