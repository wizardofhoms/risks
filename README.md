
`R.I.S.K.S` (Relatively Insecure System for Keys and Secrets) is a tool suite for creating, using and managing
different online identities, centered around cryptographic autentication (GPG), communication (SSH) and password
secrets (pass) and QubesOS, with an emphasis on seggregating and isolating these identities and their data.

The original idea and associated script can be found in the [risks-scripts](https://github.com/19hundreds/risks-scripts) repository, along with the associated [tutorials](https://19hundreds.github.io/risks-workflow).

# Summary

This repository provides a CLI (`risks`) to be used in a vault VM. Its purpose is to:
- Create, use, manage and delete identities with some core cryptographic identifiers and secrets (GPG, SSH, passwords)
- Minimize the cognitive load of managing identities, secrets and passwords, without compromising on technical and cryptographic strengh.
- Provide a strong isolation between these identities and their filesystems.
- Create, delete and manage encrypted and authenticated data directories to store arbitrary data.
- Manage devices used to store identities' data and to back them up.
- Provide all the functionality in a single CLI tool with enhanced usability, logging, checks and completions.
- Provide a structured and clean code base, for easier review of complex/critical workflows, and facilitate development contributions.

The `risks` CLI provided in this repository is independent from the `risk` CLI tool used in dom0, which you can find [here](https://github.com/wizardofhoms/risk).

# What to expect from using the RISKS tool 

Setting up RISKS and following its workflow results in:
- Just four (4) passphares to memorize to manage all the secrets (doesn’t matter how many identities or how many secrets)
- An encrypted sdcard configured for hosting private keys
- An isolated qube (virtual machine) configured for:
    - Managing GPG configurations for multiple identities
    - Managing credentials using pass
    - Managing SSH configurations for multiple identities
    - Managing multiple encrypted filesystems (embedded in a file) for multiple identities
    - Providing a secure access to GPG and SSH keys from any other qube
- A set of scripts to manage the workflow comfortably
- Disaster recovery and backup procedures


# Documentation

* [Software used](https://github.wizardofhoms/risks/wiki/Software-Used)
* [RISKS architecture in Qubes](https://github.wizardofhoms/risks/wiki/RISKS-Architecture-In-Qubes)
* [Components and roles](https://github.wizardofhoms/risks/wiki/Components-And-Roles)
* [Components workflow](https://github.wizardofhoms/risks/wiki/Components-Workflow)
* [Installation](https://github.wizardofhoms/risks/wiki/Installation)
* [Development](/https://github.wizardofhoms/risks/wiki/Development)
* [Full workflow example](/https://github.wizardofhoms/risks/wiki/Full-Workflow-Example)
* [Additional workflows](/https://github.wizardofhoms/risks/wiki/Additional-Workflows)
* [Command-line API](/https://github.wizardofhoms/risks/wiki/Command-Line-API)
