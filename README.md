# Testing Spring Boot Application

[![Build Status](https://travis-ci.org/eduardoperrino/testing-hub.svg?branch=master)](https://travis-ci.org/eduardoperrino/testing-hub)

Este repositorio contiene una aplicación *Spring Boot* con una serie de ejemplos de testing que tratan de mostrar los diferentes niveles definidos en la denominada [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html). Intenta mostrar una manera de probar a fondo una aplicación basada en *Spring* demostrando los diferente tipos y niveles de testing. Es importante tener en cuenta que su objetivo es meramenta educativo, con lo que se podrá encontrar algunos tests duplicados o conceptos ya testeados en un menor nivel en un nivel más alto contradiciendo la premisa de [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html).

## Empezamos

### 1. Configurar una API Key como Variable de Entorno
Para ejecutar el servicio, se necesita definitir la variable de entorno `WEATHER_API_KEY` con una API key valida obtenida en [darksky.net](http://darksky.net).

Una forma sencilla para hacer esto es renombrar como `.env` el fichero `env.sample` con la API key de `darksky.net` y ejecutar el fichero antes de lanzar tu aplicación:

```bash
source .env
```

### 2. Arrancar una base de datos PostgreSQL
La forma más sencilla para realizar este paso es utilizar el script `startDatabase.sh` incluído. Este script arranca un contenedor Docker que contiene una base de datos con la siguiente configuración:
    
  * port: `1543`
  * username: `postgres`
  * password: `password`
  * database name: `postgres`

Si no quieres utilizar este script asegúrate que la base de datos tiene la misma configuración que está definida en tu `application.properties`.

### 3. Arranca la aplicación
Una vez que has definido la API key e iniciada la base de datos PostgreSQL puedes arrancar la aplicación lanzando

```bash
./gradlew bootRun
```

La aplicación arrancará en el puerto `8080`, para probar que se ha levantado y se está ejecutando correctamente puedes lanzar la siguiente petición de prueba `http://localhost:8080/hello`.


## Arquitectura de la aplicación (Application Architecture)

```
 ╭┄┄┄┄┄┄┄╮      ┌──────────┐      ┌──────────┐
 ┆   ☁   ┆  ←→  │    ☕     │  ←→  │          │
 ┆  Web  ┆ HTTP │  Spring  │      │ Database │
 ╰┄┄┄┄┄┄┄╯      │  Service │      └──────────┘
                └──────────┘
                     ↑ JSON/HTTP
                     ↓
                ┌──────────┐
                │    ☁     │
                │ Weather  │
                │   API    │
                └──────────┘
```
La aplicación de ejemplo se ha intentado hacer de la forma más sencilla posible. Almacena `Person`s en una base de datos (utilizando _Spring Data_) y ofrece una interfaz _REST_ con tres endpoints:

  * `GET /hello`: Devuelve _"Hello World!"_. Siempre.
  * `GET /hello/{lastname}`: Busca la persona con `lastname` como su last name y devuelve _"Hello {Firstname} {Lastname}"_ si encuentra la persona.
  * `GET /weather`: Llama a [weather API](https://darksky.net) via HTTP and devuelve el resumen de las actuales condiciones meteorológicas en Bilbao

### Arquitectura Interna (Internal Architecture)
Este **Spring Service** tiene una arquitectura interna bastante común:

  * `Controller` clases que contienen los endpoint _REST_  y se ocupan de las peticiones y respuestas _HTTP_
  * `Repository` clases que interactúan con la _base de datos_ y se encargan de escribir y leer en/desde la almacenamiento persistente
  * `Client` clases que hablan con otras APIs, en nuestro caso recuperan datos en formato _JSON_ via _HTTP_ del weather API de darksky.net


  ```
  Request  ┌────────── Spring Service ───────────┐
   ─────────→ ┌─────────────┐    ┌─────────────┐ │   ┌─────────────┐
   ←───────── │  Controller │ ←→ │  Repository │←──→ │  Database   │
  Response │  └─────────────┘    └─────────────┘ │   └─────────────┘
           │         ↓                           │
           │    ┌──────────┐                     │
           │    │  Client  │                     │
           │    └──────────┘                     │
           └─────────│───────────────────────────┘
                     │
                     ↓   
                ┌──────────┐
                │    ☁     │
                │ Weather  │
                │   API    │
                └──────────┘
  ```  

## Capas de Testing (Test Layers)
La aplicación de ejemplo muestra las diferentes capas de testing de acerdo a [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html). 

```
      ╱╲
  End-to-End
    ╱────╲
   ╱ Inte-╲
  ╱ gration╲
 ╱──────────╲
╱   Unit     ╲
──────────────
```

La base de la pirámide esta compuesta por los tests unitarios. Deben de ser la parte más grande del conjunto de pruebas automatizadas.


En la siguiente capa se encuentran los test de integración. Pruebas todas las partes de la aplicación donde se serializan o deserializan datos. Tu REST API, Repositorios y llamadas a servicios de terceros son buenos ejemplos. En el código podrás ver ejemplos de todos estos tests.

```
 ╭┄┄┄┄┄┄┄╮      ┌──────────┐      ┌──────────┐
 ┆   ☁   ┆  ←→  │    ☕     │  ←→  │    💾    │
 ┆  Web  ┆      │  Spring  │      │ Database │
 ╰┄┄┄┄┄┄┄╯      │  Service │      └──────────┘
                └──────────┘

  │    Controller     │      Repository      │
  └─── Integration ───┴──── Integration ─────┘

  │                                          │
  └────────────── Acceptance ────────────────┘               
```

```
 ┌─────────┐  ─┐
 │    ☁    │   │
 │ Weather │   │
 │   API   │   │
 │  Stub   │   │
 └─────────┘   │ Client
      ↑        │ Integration
      ↓        │ Test
 ┌──────────┐  │
 │    ☕     │  │
 │  Spring  │  │
 │  Service │  │
 └──────────┘ ─┘
```

## Herramientas
A lo largo de los ejemplos podrás ver que se han utilizado las siguientes herramientas, frameworks y librerias:

  * **Spring Boot**: application framework
  * **JUnit**: test runner
  * **Hamcrest Matchers**: assertions
  * **Mockito**: test doubles (mocks, stubs)
  * **MockMVC**: testing Spring MVC controllers
  * **RestAssured**: testing the service end to end via HTTP
  * **Wiremock**: provide HTTP stubs for downstream services

