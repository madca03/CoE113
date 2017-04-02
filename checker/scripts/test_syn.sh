#!/bin/bash
cd ../sim
vcs -f ../scripts/dep_syn.f -full64 -debug_pp -R +neg_tchk +define+SDF -l vcs.log
