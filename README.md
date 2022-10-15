
# R.I.S.K.S Identity management (Vault) 

## Summary

`R.I.S.K.S` (Relatively Insecure System for Keys and Secrets) is a tool suite for creating, using and managing
different online identities, centered around cryptographic autentication (GPG), communication (SSH) and website
secrets (pass), with an emphasis on seggregating and isolating these identities, as well as their secrets.

The original idea and associated script can be found in the [risks-scripts](https;//github.com/19hundreds/risks-scripts) repository, along with the associated [tutorials](https://19hundreds.github.io/risks-workflow).
However, the concepts used by the tools (both original and this new version) are numerous. Consequently, the workflows
in the original version and tutorials are quite hard to follow, grasp and perform correctly. 
Therefore, one of the main purposes of this new version is to condense the original functionality into easy-to-use
commands, with added functionality and checks, better security and isolation between identities, enhanced logging, 
exhaustive completions, and more.

This tool requires a dedicated device (the _hush_ device) to store - and have access to - the identites' master
secrets, used to encrypt/lock/unlock some of their critical components, such as coffins (LUKS) and tomb keys.

Various functionality are provided by the tool, such as the possibility to backup identities' data, format new
drives dedicated to using these identities, all within a single zsh script. The `risks` script available in this 
repositoty is totally independent from the `risk` dom0 tool.


## Security principles and features

A general overview of the `risks` script purposes and features is given below. 
While some of them are inherent to the original version, many are also specific to the new version.

- Easy creation, management and use of an arbitrary number of identities and their associated stores/data.
- Functionality and workflows bundled into a single CLI, with easy-to-use commands, and detailed help.
- Strong isolation of identities, assuming the vault might be compromised and attackers having full access.
- Easy but secure management of (arbitrary number of) identity secrets, with the use of tools like `spectre`.
- All identity data encrypted and only accessible by this identity.
- Detailed completions for easier use of the tool and reducing potential usage mistakes.
- Efficient and concise worklow logging, with detailed errors and verbose logging options.

## Table of Contents

- [R.I.S.K.S Identity management (Vault)](#risks-identity-management-vault)
    - [Summary](#summary)
    - [Security principles and features](#security-principles-and-features)
    - [Table of Contents](#table-of-contents)
    - [Typical usage example](#typical-usage-example)
    - [Installation](#installation)
        - [Notes](#notes)
        - [Installing required packages](#installing-required-packages)
        - [Installing risks](#installing-risks)
        - [Initial setup](#initial-setup)
    - [Development](#development)
        - [Installing bashly](#installing-bashly)
        - [Development workflow](#development-workflow)
    - [Additional usage workflows](#additional-usage-workflows)
    - [Command-line API](#command-line-api)

## Typical usage example

## Installation

### Notes
### Installing required packages 
### Installing risks
### Initial setup

## Development

### Installing bashly
### Development workflow

## Additional usage workflows

## Command-line API

