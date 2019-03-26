#!/bin/bash

acpi_listen | perl -lane 'BEGIN { @msg = ("On battery", "On line"); } next unless $F[0] eq "ac_adapter"; print $msg[int $F[3]]'
