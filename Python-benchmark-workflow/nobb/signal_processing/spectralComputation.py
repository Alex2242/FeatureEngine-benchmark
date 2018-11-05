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

import numpy as np


def spectralComputation(signal, fs, windowFunction, windowSize, nfft, windowOverlap):
    nWindows = 1 + (signal.shape[0] - windowSize) // windowOverlap

    shape = (nWindows, windowSize)
    strides = (nWindows * signal.strides[0], signal.strides[0])

    windows = np.lib.stride_tricks.as_strided(signal, shape=shape, strides=strides)

    windowedSignal = windows * windowFunction

    rawFFT = np.fft.rfft(windowedSignal, nfft)

    vFFT = rawFFT * np.sqrt(1.0 / windowFunction.sum() ** 2)

    periodograms = np.abs(rawFFT) ** 2

    vPSD = periodograms / (fs * (windowFunction ** 2).sum())

    vWelch = np.mean(vPSD, axis=0)

    return vFFT, vPSD, vWelch
