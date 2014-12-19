#!/bin/bash

PORT="8080"

echo "Dump BrowsingCounter ..."
curl localhost:${PORT}/beagle/browsingCount?action=dump\&threshold=3

echo "Dump CuttingCounter ..."
curl localhost:${PORT}/beagle/cuttingCount?action=dump\&threshold=3
