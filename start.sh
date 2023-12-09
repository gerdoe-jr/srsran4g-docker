#!/bin/bash

sudo srsenb &   # start enb
sleep 30        # wait enb to initialize usrp
sudo srsepc &   # start epc

wait -n         # wait something to fail

exit $?
