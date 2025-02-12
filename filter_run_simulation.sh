#!/bin/bash

filtro="numCycles|idleCycles|dcache.overallHits|ReadReq.hits"
# filtro:
./run_simulation.sh | grep -E "$filtro"