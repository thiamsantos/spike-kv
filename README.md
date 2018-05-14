# Spike

[![Build Status](https://travis-ci.com/thiamsantos/spike.svg?branch=master)](https://travis-ci.com/thiamsantos/spike)

> Key-value database powered by elixir.

## Usage

```sh
$ git clone https://github.com/thiamsantos/spike.git
$ cd spike
$ mix run --no-halt
```

Now in another window open a connection with the tcp socket:

```sh
$ nc 127.0.0.1 4040 # or telnet 127.0.0.1 4040
```

### Example

```sh
SET cool_key awesome
OK
GET cool_key
awesome
OK
```

## Available commands

- `SET`. Ex: `SET key value`
- `GET`. Ex: `GET key`

## License

[Apache License, Version 2.0](LICENSE) © [Thiago Santos](https://github.com/thiamsantos)
