# unifi-timelapse

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.md)


> Follow the steps in the [documentation](http://graze.github.io/skeleton-project/#quick-start) to set up the project and
> delete this block quote.

unifi-timelapse is a script to get unifi video recordings from the NVR, merge every day and speed it up

## Install

```bash
$ git clone https://github.com/entropie/unifi-timelapse.git
$ cd unifi-timelapse
$ cp vendor/unifi-protect-remux ~/bin
```

## Usage

Make sure you setup your NVR:

```bash
$ scp vendor/unifi-protect-remux/prepare.sh username@cloudkey2:
$ echo 'cat ~/.ssh/your_key.pub | ssh cloudkey2 "cat >> .ssh/authorized_keys"'
```


```bash
./bin/unifi-timelapse.rb --day 2021-01-10 -D
```

## Change log

Please see [CHANGELOG](CHANGELOG.md) for more information what has changed recently.

## Testing

```shell
```

## Credits

- [__entropie__](https://github.com/__entropie__)

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
