
`R.I.S.K.S` (**R**elatively **I**nsecure **S**ystem for **K**eys and **S**ecrets) is a tool suite for creating, using and managing
different online identities, centered around cryptographic autentication (GPG), communication (SSH) and password
secrets (pass) and QubesOS, with an emphasis on seggregating and isolating these identities and their data.

The original idea and associated script can be found in the [risks-scripts](https://github.com/19hundreds/risks-scripts) repository, along with the associated [tutorials](https://19hundreds.github.io/risks-workflow).

# Vault

This repository provides a CLI (`risks`) to be used in a **vault VM**. Its purpose is to:
- Create, use, manage and delete identities with some core cryptographic identifiers and secrets (GPG, SSH, passwords)
- Minimize the cognitive load of managing identities, secrets and passwords, without compromising on technical and cryptographic strengh.
- Provide a strong isolation between these identities and their filesystems.
- Create, delete and manage encrypted and authenticated data directories to store arbitrary data.
- Prepare, format and manage devices used to store identities' data. 
- Easily backup identities data and secrets.
- Provide all the functionality in a single CLI tool with enhanced usability, logging, checks and completions.
- Provide a structured and clean code base, for easier review of complex/critical workflows, and facilitate development contributions.

The `risks` CLI provided in this repository is independent from the `risk` CLI tool used in dom0, which you can find [here](https://github.com/wizardofhoms/risk).

# Documentation

* [Software used](https://github.com/wizardofhoms/risks/wiki/Software-Used)
* [Components and roles](https://github.com/wizardofhoms/risks/wiki/Components-And-Roles)
* [Components workflow](https://github.com/wizardofhoms/risks/wiki/Components-Workflow)
* [Installation](https://github.com/wizardofhoms/risks/wiki/Installation)
* [Usage tutorial](https://github.com/wizardofhoms/risks/wiki/Usage-Tutorial)
* [Additional workflows](/https://github.com/wizardofhoms/risks/wiki/Additional-Workflows)
* [Command-line API](/https://github.com/wizardofhoms/risks/wiki/Command-Line-API)
* [Development](/https://github.com/wizardofhoms/risks/wiki/Development)
