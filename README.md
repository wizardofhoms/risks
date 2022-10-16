
`R.I.S.K.S` (Relatively Insecure System for Keys and Secrets) is a CLI tool for creating, using and managing
different online identities, centered around cryptographic autentication (GPG), communication (SSH) and website
secrets (pass), with an emphasis on seggregating and isolating these identities and their data.

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
  root passwords and GPG passphrases are never written to disk, rather they are derived from some parameters.
- Detailed completions for easier use of the tool and reducing potential usage mistakes.
- Efficient and concise worklow logging, with detailed errors and verbose logging options.
- Structured codebase for easier review and development, while preserving usability.
- Fail early and fail safe; various checks and validations at different steps (CLI parsing, execution, etc)

# Table of Contents

- [Summary](#summary)
- [Security principles and features](#security-principles-and-features)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
    - [Notes](#notes)
    - [Installing required packages](#installing-required-packages)
        - [TemplateVM packages](#templatevm-packages)
        - [AppVM vault packages](#appvm-vault-packages)
    - [Remaining setup](#remaining-setup)
        - [In the TemplateVM](#in-the-templatevm)
        - [In the vault AppVM](#in-the-vault-appvm)
    - [Installing risks](#installing-risks)
    - [Initial setup](#initial-setup)
- [Development](#development)
    - [Installing bashly](#installing-bashly)
    - [Code base](#code-base)
        - [Structure](#structure)
        - [Additional notes on the code](#additional-notes-on-the-code)
        - [Conventions on code structure](#conventions-on-code-structure)
    - [Development workflow (adding commands)](#development-workflow-adding-commands)
- [Additional usage workflows](#additional-usage-workflows)
- [Command-line API](#command-line-api)

# Installation

## Notes

- There are only two files to be installed in the vault VM: the `risks` CLI, and its `_risks` completion script.
  Since these scripts are used to handle sensitive data, you should spend the **required** time to thorougly review
  the code in them. A good hour should be needed for this, since these scripts are quite long (although most
  of the CLI is auto-generated, and redundant, so quickly reviewed).
- It is strongly advised to use a `debian-minimal` template for the vault: all installation instructions are
  adapted for this distribution.

## Installing required packages 

### TemplateVM packages
First, install most packages through `apt` in the TemplateVM:
```
sudo apt install zsh cryptsetup steghide dosfstools wipe xclip pass e2fsprogs qubes-gpg-split gnupg2 socat pinentry-curses ssh-akspass-gnome libnotify-bin sox haveged rng-tools
```

We then install `fscrypt`, a high-level encryption tool, and used by `risks` identities to encrypt their own directories 
(graveyards). For this tool to be built, we unfortunately need to have a Go toolchain, which needs internet access. 
The following steps should thus probably be done in another AppVM with internet access, preferably a Fedora one since 
Debian Go toolchains are outdated.
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

Finally, we install the tomb tool. First download the tomb script from a VM with internet access and copy it in our TemplateVM:
```
cd /tmp
wget -c https://files.dyne.org/tomb/Tomb-2.9.tar.gz
wget -c https://files.dyne.org/tomb/Tomb-2.9.tar.gz.sha
sha256sum -c Tomb-2.9.tar.gz.sha
qvm-copy Tomb-2.9.tar.gz
```

After, install the tomb script in the TemplateVM:
```
cd ~/QubesIncoming/<vm_where_tomb_was_downloaded>
tar xvfz Tomb-2.9.tar.gz
cd Tomb-2.9
sudo make install
cd ..
rm -fR Tomb-2.9
```

### AppVM vault packages
After this, we will install the `spectre` password tool. All the steps below (except cloning the spectre-cli repository),
are performed directly in the `vault` AppVM: thus, all build dependencies will disappear at the next reboot, and the
`spectre` binary will remain in `/usr/local/bin`. While you can simply follow the instructions below, you can also find 
them on [the spectre-cli repo](https://gitlab.com/spectre.app/cli).

Install dependencies in the AppVM: 
```
sudo apt install libncurses6 libsodium23 libjson-c5
```
In another VM with internet access, clone the spectre-cli repository, and copy it in the vault AppVM:
```
git https https://gitlab.com/spectre.app/cli
qvm-copy cli
```
In the vault AppVM, go in the directory, build the binary, run the tests, and install the binary (in `/usr/local/bin`):
```
cd /home/user/QubesIncoming/<disp_where_cli_wasdownloaded>/cli 
./build
./spectre-cli-tests
./install
```

## Remaining setup

### In the TemplateVM
Enable filesystem encryption in the TemplateVM, needed by fscypt. Note that although the target directories will
will not persist in the vault VM, the template holds the settings that we create with the following command:
```
sudo /sbin/tune2fs -O encrypt /dev/xvdb     # xvdb the device storing the /rw filesystem
```
In the TemplateVM, initialize the fscrypt tool (which will create a conf in `/etc/fscrypt.conf` 
and a `/.fscrypt` directory). Answer "yes" to the fscrypt prompt, then shutdown the template:
```
sudo fscrypt setup
sudo poweroff
```

### In the vault AppVM
First, we disable history in the VM. ZSH, by default does not save any history. Ensure you don't have these settings in `.zshrc`.
For `bash`, use the following commands:
```
echo 'unset HISTFILE' >> .bashrc
source .bashrc
wipe -f .bash_history
```
Then, we disable swap for the VM, since `tomb` requires it to be off.
```
sudo sh -c "sed 's/bin\/sh/bin\/bash/g' -i /rw/config/rc.local"
sudo sh -c 'echo "swapoff -a" >> /rw/config/rc.local'
```
We poweroff the vault AppVM, and start it again to install the `risks` scripts.

## Installing risks

Now that our vault VM is fully set up with required tools, we can install the `risks` tools.
Download one of the releases, containing the CLI and its completions, and move them to the vault AppVM:
```
wget
```

Copy the files to their respective places (adapt the directories of this example), and launch a new terminal to load changes:
```bash
# Command script
sudo cp QubesIncoming/joe-dvq/risks /usr/local/bin/risks && sudo chmod +x /usr/local/bin/risks
# Completions
sudo mkdir -p /usr/local/share/zsh/site-functions
sudo cp QubesIncoming/joe-dvq/_risks /usr/local/share/zsh/site-functions/_risks
```

## Initial setup

A few things remain to be done for `risks` to work correctly. First, run the CLI without command.
This will create a `~/.risks/` directory and will write the default configuration file in it:
```
$ risks
risks  .  Creating RISKS directory in /home/user/.risks
risks  .  Writing default configuration file to /home/user/.risks/config.ini
```

You can check the generated configuration file `~/.risks/config.ini`, which stores all values needed by `risks`.
By default, none of those settings need to be changed. Should you want to modify them, you can either edit
the configuration file in place, or use `risks config set <variable> <value>` commands (autocompleted).


# Development

In order to ease development and keep the (rather large) codebase structured, the [bashly CLI framework](https://bashly.dannyb.co) is used.

## Installing bashly

Bashly requires ruby, and the bashly gem. To install all of them in the TemplateVM:
```
sudo apt install ruby
gem install bashly
sudo poweroff
```
Alternatively, if you want to install the bashly gem in the development AppVM:
```
gem install --user-install bashly
```

## Code base 

### Structure
The codebase is structured according to bashly conventions and usage.
- `settings.yml` holds the general settings used by bashly when searching for YAML declarations, 
  shell code, and for generating the final script.
- `Makefile` is used to adjust for a few things that bashly doesn't handle, and to bundle the 
  process into one command/workflow.
- `risks` is the final generated CLI script.
- `src/` contains all the code needed by bashly to generate our CLI script.

In `src/`, the code is structured as the following:
- `<command_files>...` - All files corresponding to CLI commands. Note that they are named 
- `lib/` - Contains the code used by CLI commands in `src/`, split into files depending on their role. 
- `lib/validations/` - Contains all functions used to validate CLI args/flags when parsing command.
  after their CLI command position (eg. `risks hush format` command code is contained in `hush_format_command.sh`)

In the `src/` directory, some files have a special role:
- `bashly.yml` is the root YAML declaration scanned by bashly. It comprises the list of required binaries,
  a list of other YAML files in which commands are declared, the version tag (generated in the `Makefile`),
  and some hidden commands.
- `hush_commands.yml` is an example of YAML file in which commands are declared, here the `hush` subcommand and
  its own subcommands, along with their arguments, flags, help string, example usage, etc.
- `header.sh` contains the shebang header to be included at the top of our final CLI script (here, a `zsh` shebang)
- `initialize.sh` contains shell code that is to be executed before any command is actually run. In this script,
  we initialize global variables (sometimes parsing them from the `risks` configuration file), and perform other
  pre-run checks that are not handled by the rest of our code.

### Additional notes on the code
- Although the resulting script is a ZSH script (with the corresponding shebang header), all files in the `src/` 
  directory must have the `.sh` extension for bashly to scan and recognize them.
- Note that although each `<subject>_command.sh` file does not declare a corresponding function, bashly will
  actually include the code in the file into a function named `risks_subject_command`, so if you happen to
  develop with checkers like shellcheck, and that warnings are raised about not being allowed to declare local
  variables, you can safely ignore/mute them. This also applies to any error/warning caused by you using zsh syntax.

### Conventions on code structure
Since bashly offers some facilities for querying our command args and flags, we try to split the functionality like this:
- Command files (eg. `hush_format_command.sh`) are charged of initializing, setting and checking the command args/flags.
- The command file then calls on specialized functions located in `src/lib/`, passing the arguments the latter require.
  Accordingly, most of the functions in the `lib/` directory do (and should) document on the parameters they require.
- As a result, some command files are only made of a single line (a `lib/` function call ).


## Development workflow (adding commands)

# Additional usage workflows

# Command-line API

