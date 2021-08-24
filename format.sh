#!/bin/bash

ocamlformat --inplace $(find tidy_email mailgun smtp -regex '.*ml[i]?')
