# Ansible playbook for dabr.ca

This repository contains Ansible playbook for [dabr.ca](https://dabr.ca/), a microblogging site powered by [Pleroma](https://pleroma.social/).

In the event that the administrator of dabr.ca is unable to fulfil their responsibilities, anyone interested can use this repo to set up as a successor. If you want to run your own instance, you may need to do a find-and-replace for hard-coded values such as domain names.

## Setup

1. Have [infra](https://github.com/dabr-ca/infra) set up already.
2. Run `ansible-playbook site.yaml` to install and configure Pleroma.
3. [Perform database migration tasks](https://docs-develop.pleroma.social/backend/installation/otp_en/).
4. Start Pleroma with `systemctl start pleroma`.
