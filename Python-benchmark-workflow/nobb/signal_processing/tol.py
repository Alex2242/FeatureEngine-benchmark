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


import numpy as np
import scipy.signal
import scipy.fftpack
from math import floor, log10

# We're using some accronymes here:
#   toc: third octave center
#   tob: third octave band


def tol(psd, samplingRate, nfft,
        lowFreq=None, highFreq=None):

    lowerLimit = 1.0
    upperLimit = max(samplingRate / 2.0,
                     highFreq if highFreq is not None else 0.0)

    if (lowFreq is None):
        lowFreq = lowerLimit

    if (highFreq is None):
        highFreq = upperLimit

    # when wrong lowFreq, highFreq are given,
    # computation falls back to default values
    if not lowerLimit <= lowFreq < highFreq <= upperLimit:
        lowFreq, highFreq = lowerLimit, upperLimit

    maxThirdOctaveIndex = floor(10 * log10(upperLimit))

    tobCenterFreqs = np.power(10, np.arange(0, maxThirdOctaveIndex+1)/10)

    def tobBoundsFromTOC(centerFreq):
        return centerFreq * np.power(10, np.array([-0.05, 0.05]))

    allTOB = np.array([tobBoundsFromTOC(tocFreq)
                       for tocFreq in tobCenterFreqs])

    tobBounds = np.array([tob for tob in allTOB
                          if tob[1] >= lowFreq
                          and tob[0] < highFreq
                          and tob[1] < upperLimit])

    def boundToIndex(bound):
        return np.array([floor(bound[0] * nfft / samplingRate),
                         floor(bound[1] * nfft / samplingRate)],
                        dtype=int)

    tobIndicies = np.array([boundToIndex(bound) for bound in tobBounds])

    ThridOctavePowerBands = np.array([
        np.sum(psd[indicies[0]:indicies[1]]) for indicies in tobIndicies
    ])

    tols = 10 * np.log10(ThridOctavePowerBands)

    return tols
