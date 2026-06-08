#!/bin/bash

argocd cluster add "$(kubectl config get-contexts -o name)" --yes