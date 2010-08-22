#!/bin/bash

SWAPS="Three20Core Three20Network Three20UICommon Three20Style Three20UINavigator Three20UI"

# I really dont know perl that well so please make this faster - Jamie

for swap in $SWAPS; do
	find * -exec perl -p -i -e "s/$swap\//Six40\//g;" {} \;
done

find * -exec perl -p -i -e "s/Six40\/private/Six40/g;" {} \;
