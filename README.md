# Template de Proyecto Ruby para Objetos 3 (UNQ)


## Setup

La primera vez que clonen el repositorio deberan instalar las dependencias que ya tenemos definidas en Gemfile (rspec), para esto tienen que tener instalado `ruby` y `bundler`.

Checkear que tengo Ruby

```bash
> ruby -v
ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux]
```

Checkear que tengo Bundler

```bash
bundle -v
> Bundler version 2.1.4
```

Ahora sí, instalamos con

```bash
bundle install
```

## Ejectuar los tests

Desde consola

```bash
bundle exec rspec spec
```

