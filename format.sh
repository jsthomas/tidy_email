#!/bin/bash

ocamlformat --inplace $(find tidy_email mailgun smtp sendgrid -regex '.*ml[i]?')
