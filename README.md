# Pass-Qt

A simple GUI for pass on Linux.

## Requirements

- [Ruby 3.4+](https://www.ruby-lang.org/)
- [Qt 6.10+](https://www.qt.io/)
- **one of the following password managers**
    - [pass](https://www.passwordstore.org/) & [pwgen](https://sourceforge.net/projects/pwgen/)
    - [gopass](https://github.com/gopasspw/gopass)

## Installation

```console
$ gem install ruby-pass-qt
```

## Usage

To initialize the password store:

```console
$ pass init new_gpg-id_or_email
```

To launch the GUI:

```console
$ pass-qt
```

## Screenshot

![screenshot](https://github.com/souk4711/ruby-pass-qt/raw/main/screenshot.png)

## License

Licensed under the [GPL-3.0-only](./LICENSE).
