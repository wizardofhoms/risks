
`R.I.S.K.S` (Relatively Insecure System for Keys and Secrets) is a CLI tool for creating, using and managing
different online identities, centered around cryptographic autentication (GPG), communication (SSH) and website
secrets (pass), with an emphasis on seggregating and isolating these identities, as well as their secrets.

The original idea and associated script can be found in the [risks-scripts](https://github.com/19hundreds/risks-scripts) repository, along with the associated [tutorials](https://19hundreds.github.io/risks-workflow).
However, the concepts used by the tools (both original and this new version) are numerous. Consequently, the workflows
in the original version and tutorials are quite hard to follow, grasp and perform correctly. 
Therefore, one of the main purposes of this new version is to condense the original functionality into easy-to-use
commands, with added functionality and checks, better security and isolation between identities, enhanced logging, 
exhaustive completions, and more.

# Summary

This repository provides a CLI (`risks`) to be used in a vault VM, and this tool is totally independent from the
`risk` CLI tool used in dom0, which you can find [here](https://github.com/wizardofhoms/risk).

This tool requires a dedicated device (the _hush_ device) to store - and have access to - the identites' master
secrets, used to encrypt/lock/unlock some of their critical components, such as coffins (LUKS) and tomb keys.
Accessorily, another device can be used as backup medium for all or some identites.

Various functionality are provided by the tool, such as the possibility to backup identities' data, format new
drives dedicated to using these identities, all within a single zsh script.

# Security principles and features

A general overview of the `risks` script purposes and features is given below. 
While some of them are inherent to the original version, many are also specific to the new version.

- Easy creation, management and use of an arbitrary number of identities and their associated stores/data.
- Functionality and workflows bundled into a single CLI, with easy-to-use commands, and detailed help.
- Strong isolation of identities, assuming the vault might be compromised and attackers having full access:
  all directories and files for identities are encrypted and obfuscated.
- Easy but secure management of (arbitrary number of) identity secrets, with the use of tools like `spectre`:
  root passwords and GPG passphrases are never written to disk, rather they are deterministically generated.
- Detailed completions for easier use of the tool and reducing potential usage mistakes.
- Efficient and concise worklow logging, with detailed errors and verbose logging options.
- Structured codebase for easier review and development, while preserving usability.
- Fail early and fail safe; various checks and validations are different steps (CLI parsing, execution, etc)

# Table of Contents

- [Summary](#summary)
- [Security principles and features](#security-principles-and-features)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
    - [Notes](#notes)
    - [Installing required packages](#installing-required-packages)
        - [TemplateVM packages](#templatevm-packages)
        - [AppVM vault packages](#appvm-vault-packages)
        - [Remaining vault setup](#remaining-vault-setup)
    - [Installing risks](#installing-risks)
    - [Initial setup](#initial-setup)
- [Development](#development)
    - [Installing bashly](#installing-bashly)
    - [Code base structure](#code-base-structure)
    - [Development workflow (adding commands)](#development-workflow-adding-commands)
- [Additional usage workflows](#additional-usage-workflows)
- [Command-line API](#command-line-api)

# Installation

## Notes

- There are only two files to be installed in the vault VM: the `risks` CLI, and its `_risks` completion script.
  Since these scripts are used handle sensitive data, you should spend the **required** time to thorougly review
  the code in them. A good hour should be needed for this, since these scripts are quite long (although most
  of the CLI is auto-generated, and redundant, so quickly reviewed).
- It is strongly advised to use a `debian-minimal` template for the vault: all installation instructions are
  adapted for this distribution.

## Installing required packages 

### TemplateVM packages

First, install most packages through `apt` in the TemplateVM:
```
sudo apt install cryptsetup steghide dosfstools wipe xclip pass e2fsprogs qubes-gpg-split gnupg2 socat pinentry-curses ssh-akspass-gnome libnotify-bin sox haveged rng-tools
```

We then install `fscrypt`, a high-level encryption tool, and used by `risks` identities to encrypt their own directories 
(graveyards). For this tool to be build, we unfortunately need to have a Go toolchain, which needs internet access. 
The following steps should thus probably be done in another VM, preferably a Fedora one since Debian Go toolchains 
are outdated.
```
sudo dnf install golang-go make pam-devel
go get -d github.com/google/fscrypt/...
cd $GOPATH/src/github.com/google/fscrypt
make
qvm-copy ./bin/fscrypt # Copy to TemplateVM
```
Then, install the produced binary into the `vault` **TemplateVM** (because we need to set the root fscrypt config):
```
sudo cp /home/user/QubesIncoming/<disp_where_fscrypt_was_build>/fscrypt /usr/bin
```

### AppVM vault packages

After this, we will install the `spectre` password tool. All the steps below (except cloning the spectre-cli repository),
are performed directly in the `vault` AppVM: thus, all build dependencies will disappear at the next reboot, and the
`spectre` binary will remain in `/usr/local/bin`. While you can simply follow the instructions below, you can also find 
them on [the spectre-cli repo](https://gitlab.com/spectre.app/cli).

Install dependencies in the AppVM. Since is done in the vault AppVM so that they disappear on the next reboot:
```
sudo apt install libncurses6 libsodium23 libjson-c5
```
In another VM with internet access, clone the spectre-cli repository, and copy it in the vault AppVM:
```
git https https://gitlab.com/spectre.app/cli
qvm-copy cli
```
In the vault AppVM, go in the directory, build the binary, run the test, and install the binary (in `/usr/local/bin`):
```
cd /home/user/QubesIncoming/<disp_where_cli_wasdownloaded>/cli 
./build
./spectre-cli-tests
./install
```

### Remaining vault setup


## Installing risks
## Initial setup

# Development

## Installing bashly
## Code base structure
## Development workflow (adding commands)

# Additional usage workflows

# Command-line API

