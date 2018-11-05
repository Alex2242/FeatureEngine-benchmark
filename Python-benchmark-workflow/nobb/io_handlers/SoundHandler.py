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


import soundfile, os


class SoundHandler:
    """
    @todo additionnal check on wav file
    """
    def __init__(
        self,
        fileName,
        wavFileLocation,
        sysBits,
        wavBits,
        sampleNumber,
        fs,
        chanNumber
    ):

        self.wavFileLocation = wavFileLocation
        self.fileName = fileName
        self.sysBits = sysBits
        self.wavBits = wavBits
        self.sampleNumber = sampleNumber
        self.fs = fs
        self.chanNumber = chanNumber



    def read(self):
        sig, fs = soundfile.read(os.path.join(self.wavFileLocation, self.fileName))

        assert(self.fs == fs)
        assert(len(sig) == self.sampleNumber)

        return sig, fs

