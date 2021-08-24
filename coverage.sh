#!/bin/bash

dune runtest --instrument-with bisect_ppx --force
bisect-ppx-report html
