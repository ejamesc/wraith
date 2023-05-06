# Wraith

[![shellcheck](https://github.com/ngshiheng/wraith/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ngshiheng/wraith/actions/workflows/shellcheck.yml)

A simple utility Bash script to backup [Ghost](https://github.com/TryGhost/Ghost) publishing platform. This script enables Ghost users to quickly and easily back up their entire platform, including the MySQL database.

## Context

Getting started with Ghost is easy. You would pick between:

-   [Managed](https://ghost.org/pricing/) service
-   Self-hosted on a [VPS](https://marketplace.digitalocean.com/apps/ghost) or serverless platform like [Railway](https://blog.railway.app/p/ghost)

Using managed version will most likely save you a bunch of headaches (and time) that come along with self-hosting any other sites:

-   Backups
-   Maintenance
-   Downtime recovery
-   Security, etc.

In short, you’d sleep easy at night while they stay awake.

Having that said, if you want to take on the challenge of self-hosting your own Ghost site, here's a tiny script to help with your backups.

[Read more...](https://jerrynsh.com/backing-up-ghost-blog-in-5-steps/)

## Table of Contents

- [Wraith](#wraith)
  - [Context](#context)
  - [Table of Contents](#table-of-contents)
  - [Flowchart](#flowchart)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Usage](#usage)
  - [FAQ](#faq)
  - [Contributing](#contributing)
  - [License](#license)

## Flowchart

```mermaid
graph LR
  1(["start"]) --> 2["run checks"] --> 3["clean up"] --> 4["run `ghost backup`"] --> 5["run `mysqldump`"] --> 6["`rclone` backups to cloud storage"] --> 7["clean up"] --> 8(["end"])
```

## Requirements

> 💡 Tip: run `make check` to check if all requirements are installed.

A list of CLI required to be installed:

-   [`expect`](https://manpages.ubuntu.com/manpages/impish/man1/expect.1.html)
-   [`ghost`](https://ghost.org/docs/ghost-cli/)
-   [`gzip`](https://www.gnu.org/software/gzip/)
-   [`mysql`](https://www.mysql.com/)
-   [`rclone`](https://rclone.org/install/)

## Setup

> 💡 Tip: run `make help` to display help message.
>
> Check out the [Makefile](./Makefile)

Run `make setup` to set up [`rclone`](docs/FAQ.md#how-to-set-up-rclone), `autoexpect`, and [`cron`](docs/FAQ.md#how-to-set-up-a-cron-job).

## Usage

1. Access your Virtual Private Server (VPS) where your Ghost site is hosted
2. Utilize the `sudo -i -u ghost-mgr` command to switch to the `ghost-mgr` user, which is responsible for managing Ghost
3. Clone the repository onto the VPS
4. Configure `rclone` and `autoexpect` once (or execute the `make setup` command)
5. Execute the `./backup.sh` command from within the cloned repository directory (or utilize `make backup`). This will run the backup script and initiate the backup process

## FAQ

See [FAQ.md](docs/FAQ.md).

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).
