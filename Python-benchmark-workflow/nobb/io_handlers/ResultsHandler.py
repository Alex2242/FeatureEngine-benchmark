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

# Authors: Dorian Cazau, Alexandre Degurse

import os


class ResultsHandler:
    def __init__(
        self,
        wavFileName,
        segmentSize,
        windowSize,
        nfft,
        windowOverlap,
        resultsDestination="../../resources/results/python_vanilla",
        vSysBits=64
    ):


        self.wavFileName = wavFileName
        self.segmentSize = segmentSize
        self.windowSize = windowSize
        self.nfft = nfft
        self.windowOverlap = windowOverlap
        self.vSysBits = vSysBits
        self.resultsDestination = resultsDestination

    def __str__(self):
        # crop wav file extention from wavFileName
        return "{}-{}-{}-{}".format(self.wavFileName[:-4], self.segmentSize, self.windowSize,
                                    self.nfft, self.windowOverlap, self.vSysBits)



    def write(self, results):
        results.to_json(os.path.join(self.resultsDestination, str(self)) + ".json", double_precision=15)

