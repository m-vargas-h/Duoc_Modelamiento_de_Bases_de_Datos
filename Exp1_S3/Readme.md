# Experiencia 1: Semana 3 - Modelando cardinalidad entre entidades

---

## Descripción del sistema

Este sistema permite gestionar de forma centralizada la información de residentes, contratos, anexos, habitaciones, personal y afiliados en residencias para adultos mayores. Está diseñado para ser extensible, mantenible y alineado con buenas prácticas de modelado de datos.

---

## Estructura del modelo

### Entidades principales

- **RESIDENTE**: Persona que habita la residencia, clasificada como permanente o temporal.
- **CONTRATO**: Acuerdo formal entre la residencia y el afiliado, puede incluir anexos.
- **ANEXO**: Documento adicional que complementa un contrato.
- **AFILIADO**: Persona responsable del residente, con vínculo contractual.
- **HABITACION**: Espacio físico asignado al residente.
- **RESIDENCIA**: Institución que contiene habitaciones y personal.
- **PERSONAL**: Trabajadores de la residencia, subdivididos en cuidadores y médicos.

### Subtipos

| Supertipo   | Subtipos                 |
|-------------|--------------------------|
| `RESIDENTE` | `PERMANENTE`, `TEMPORAL` |
| `PERSONAL`  | `CUIDADOR`, `MEDICO`     |

---

## Relaciones clave

| Participantes                   | Cardinalidad | Descripción breve                           |
|---------------------------------|--------------|---------------------------------------------|
| RESIDENTE – PERMANENTE/TEMPORAL | 1:1          | Cada residente tiene un tipo, pero solo puede tener un tipo |
| RESIDENTE – HABITACION          | 1:1          | Cada residente ocupa una habitación activa |
| RESIDENCIA – HABITACION         | 1:N          | Una residencia tiene varias habitaciones    |
| CONTRATO – APODERADO            | N:1          | Cada contrato está vinculado a un apoderado |
| CONTRATO – ANEXO                | 1:N          | Un contrato puede tener varios anexos, el anexo pertenece a solo un residente |
| RESIDENTE – ANEXO               | 1:N          | Un residente puede tener varios anexos      |
| MÉDICO – MÉDICO                 | 0:1          | Relación recursiva opcional                 |

---

## Capturas del modelo

Se incluyen en el documento Word las siguientes vistas:
- MER en notación Barker
- Modelo lógico en notación Bachman

---

## Entrega técnica

- Archivo `.dmd` con el modelo completo
- Documento Word con capturas y descripción
- Enlace al repositorio GitHub con estructura organizada

---
