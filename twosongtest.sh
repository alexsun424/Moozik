#!/bin/bash

# First remove the .mid files
rm ttls.mid
rm mhall.mid

# Then remove the .ll files
rm ttls.ll
rm mhall.mid

# Run moozik.native to make the .ll files
./moozik.native -l ttls.mz > ttls.ll
./moozik.native -l mhall.mz > mhall.ll

# Make the .mid (MIDI) files
# Ignore the errors on console for now
lli ttls.ll
lli mhall.ll

# Voila, the MIDI files should be ready to play
# in youre preferred media player!