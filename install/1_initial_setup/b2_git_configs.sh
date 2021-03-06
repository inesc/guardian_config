#!/usr/bin/env sh

echo "####################################################################################################"
echo "##### Setting up git config"
echo "####################################################################################################"

git config --global user.name "inesc"
git config --global user.email crob@inesctec.pt
git config --global branch.autosetuprebase always
git config --global pull.rebase true
git config --global rebase.autostash true


echo "\n\n"
echo "####################################################################################################"
echo "##### Finished"
echo "####################################################################################################"
