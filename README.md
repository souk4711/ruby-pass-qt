# PassQt

A simple GUI for pass on Linux.

## Requirements

- [Ruby](https://www.ruby-lang.org/)
- [Qt](https://www.qt.io/)
- **one of the following password managers**
    - [pass](https://www.passwordstore.org/) & [pwgen](https://sourceforge.net/projects/pwgen/)
    - [gopass](https://github.com/gopasspw/gopass)

## Installation

```sh
gem install ruby-pass-qt
```

## Usage

To initialize the password store:

```sh
pass init new_gpg-id_or_email
```

To launch the GUI:

```sh
pass-qt
```

## Screenshot

![screenshot](https://github.com/souk4711/ruby-pass-qt/raw/main/misc/screenshots/mainwindow.png)

## License

Licensed under the [GPL-3.0-only](./LICENSE).
