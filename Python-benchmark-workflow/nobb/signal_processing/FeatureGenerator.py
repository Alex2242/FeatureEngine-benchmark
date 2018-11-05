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
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Authors: Dorian Cazau, Alexandre Degurse

import numpy
import pandas

from .tol import tol
from .spectralComputation import spectralComputation


class FeatureGenerator:
    def __init__(self, soundHandler, fs, segmentSize, windowSize, nfft, windowOverlap,
                 lowFreq=None, highFreq=None, windowFunction="hamming"):

        self.soundHandler = soundHandler
        self.fs = fs
        self.segmentSize = segmentSize
        self.windowSize = windowSize
        self.windowOverlap = windowOverlap
        self.nfft = nfft

        if windowFunction == "hamming":
            self.windowsFunction = numpy.hamming(self.windowSize)
        else:
            raise Exception("Requested window ({}) hasn't been implemented".format(windowFunction))

        if (lowFreq == None):
            self.lowFreq = 0.4 * self.fs
        if (highFreq == None):
            self.highFreq = 0.6 * self.fs

        self.results = {}

    @staticmethod
    def formatComplexResults(resultValue):
        """
        Results containing complex values are reformatted following
        the same convention as in FeatureEngine, ie:
        [z_0, z_1, ... , z_n] => [Re(z_0), Im(z_0), Re(z_1), ... Im(z_n)]
        """
        initialShape = resultValue.shape

        nWindows = initialShape[1]
        featureSize = initialShape[0]

        valueAsScalaFormat = numpy.zeros((nWindows, 2*featureSize), dtype=float)
        valueAsComplex = resultValue.transpose()

        for i in range(nWindows):
            valueAsScalaFormat[i, ::2] = valueAsComplex[i].real
            valueAsScalaFormat[i, 1::2] = valueAsComplex[i].imag

        return valueAsScalaFormat.transpose()

    def generate(self):
        """
        Function generation pre-defined features with the specified parameters
        :return: A dictionary containing the results
        """
        sound, fs = self.soundHandler.read()

        if (fs != self.fs):
            raise Exception("The given sampling rate doesn't match the one read")

        nSegments = sound.shape[0] // self.segmentSize

        segmentedSound = numpy.split(sound[:self.segmentSize * nSegments], nSegments)

        results = []

        for iSegment in range(nSegments):
            vFFT, vPSD, vWelch = spectralComputation(signal=segmentedSound[iSegment],
                                                     fs=fs, windowFunction=self.windowsFunction,
                                                     windowSize=self.windowSize, nfft=self.nfft,
                                                     windowOverlap=self.windowOverlap)

            vTOL = tol(psd=vWelch, samplingRate=self.fs, nfft=self.nfft,
                       lowFreq=self.lowFreq, highFreq=self.highFreq)

            results.append((
                FeatureGenerator.formatComplexResults(vFFT),
                vPSD,
                vWelch,
                vTOL
            ))

        return pandas.DataFrame(results, columns=("vFFT", "vPSD", "vWelch", "vTOL"))
