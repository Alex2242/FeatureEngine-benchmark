#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright (C) 2017-2018 Project-ODE
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Authors: Alexandre Degurse

from signal_processing import FeatureGenerator
from io_handlers import SoundHandler, ResultsHandler

wavFilesLocation = "../../resources/sounds"
filesToProcess = [{
    "name": "Example_64_16_3587_1500.0_1.wav",
    "fs": 1500.0,
    "wavBits": 16,
    "nSamples": 3587,
    "nChannels": 1
}]

segmentSize = 1024
windowSize = 256
nfft = 256
windowOverlap = 128

sysBits = 64

for wavFile in filesToProcess:
    soundHandler = SoundHandler(wavFile["name"], wavFilesLocation, sysBits,
                                wavFile["wavBits"], wavFile["nSamples"], wavFile["fs"], wavFile["nChannels"])

    featureGenerator = FeatureGenerator(soundHandler, wavFile["fs"], segmentSize, windowSize, nfft, windowOverlap)

    results = featureGenerator.generate()

    resultsHandler = ResultsHandler(wavFile["name"], segmentSize, windowSize, nfft, windowOverlap)

    resultsHandler.write(results)

