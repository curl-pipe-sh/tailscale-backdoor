## Waaa?

Executing the `install.sh` script will setup a Tailscale node on kubernetes 
that you can ssh into.

## Requirements

- [bash](https://www.gnu.org/software/bash/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [yq](https://mikefarah.gitbook.io/yq/)

## TL;DR: Usage

```shell
curl -fsSL pschmitt.dev/backdoor | bash -s -- --auth-key ts-key-xxxxx

# Alternative (if you don't trust me)
curl -fsSL https://raw.githubusercontent.com/pschmitt/tailscale-backdoor/HEAD/install.sh | bash -s -- --auth-key ts-key-xxxxx
```
