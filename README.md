# unifi-timelapse

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.md)

unifi-timelapse is a script to get unifi video recordings from the NVR, merge every day to a single file, speed it up and save for

## Install

```bash
$ git clone https://github.com/entropie/unifi-timelapse.git
$ cd unifi-timelapse
$ cp vendor/unifi-protect-remux/remux ~/bin
```

## Usage

Make sure you setup your NVR:

```bash
$ echo 'cat ~/.ssh/your_key.pub | ssh username@cloudkey2 "cat >> .ssh/authorized_keys"'
$ scp vendor/unifi-protect-remux/prepare.sh username@cloudkey2:
```


```bash

$ cat ~/.utl.yaml
---
:hostname: ckey2
:address: 192.168.1.2
:camera: FCECDA30E675
:sshopts: "-i ~/.ssh/for_remote"
:sshuser: mictro
:workdir: /home/mit/Work
:server_workdir: /srv/unifi-protect/video/
:speedup: 0.00027777777

# run for day 2021-01-10
./bin/unifi-timelapse.rb --day 2021-01-10 -D
```

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
