/** Copyright (C) 2017-2018 Project-ODE
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.oceandataexplorer.engine.benchmark

import java.io.File

import org.oceandataexplorer.engine.workflows._

import scala.io.Source
import java.net.URI


// scalastyle:off

/**
 * Scala Only Benchmark main object
 */
object SPMScalaOnly {
  /**
   * Function runnning benchmark workflow on the SPM Dataset
   * @param args The arguments for the run
   */
  def main(args: Array[String]): Unit = {
    val nNodes = args(0).toInt
    val nFiles = args(1).toInt
    val inputBaseDir = args(2)
    val outputBaseDir = args(3)

    val inputBaseDirFile = new File(inputBaseDir)
    val wavDir = new File(inputBaseDirFile.getCanonicalFile + "/PAM/SPMAuralA2010")
    val metadataFile = new File(inputBaseDirFile.getCanonicalFile + "/PAM/Metadata_SPMAuralA2010.csv")
    val outputBaseDirFile = new File(outputBaseDir)


    // Signal processing parameters
    val recordSizeInSec = 60.0f
    val soundSamplingRate = 32768.0f
    val recordSizeInFrame = (recordSizeInSec * soundSamplingRate).toInt
    val recordSize = (recordSizeInSec * soundSamplingRate).toInt
    val windowSize = 256
    val windowOverlap = 128
    val nfft = 256
    val lowFreqTOL = Some(0.2 * soundSamplingRate)
    val highFreqTOL = Some(0.4 * soundSamplingRate)

    // Sound parameters
    val soundPath = wavDir.getCanonicalFile.toURI.toString
    val soundChannels = 1
    val soundSampleSizeInBits = 16

    /** read metadata & drop header
     * We're using the following fields of the metadata file (semi-colon separated csv):
     *   - 0: the wav file name, eg "A32C0000.WAV"
     *   - 9: the date on which the recording begins, eg "2010-04-12"
     *   - 10: the time on which the recording begins, eg "12:41:23"
     * For more information on the metadata file content see p39 of (french):
     * http://www.multi-electronique.com/files/AURAL/user/AURAL-M2_MANUEL_D_UTILISATION.pdf
     */
    val metadata = Source.fromFile(metadataFile).mkString.split("\n").drop(1).toList

    val soundsNameAndStartDate = metadata
      .map(fileMetadata => {
        val metadataArray = fileMetadata.split(";")
        val date = metadataArray(9).replace("/", "-")
        val time = metadataArray(10)

        (metadataArray(0), date + "T" + time)
      })
      .take(nFiles)

    val soundNames = soundsNameAndStartDate.map(_._1).reduce((p,n) => p + "," + n)
    val soundsPath = soundPath + "/{" + soundNames + "}"

    val runId = s"SPM${nFiles}files_${recordSizeInFrame}_${windowSize}_${windowOverlap}_$nfft"

    val resultsDestination = outputBaseDirFile.getCanonicalFile.toURI.toString +
      s"/results/feature_engine_benchmark/$nNodes/" + runId

    val resultDestinationFile = new File(new URI(resultsDestination))

    if (!resultDestinationFile.exists()) {
      resultDestinationFile.mkdirs()
    }

    val pool = java.util.concurrent.Executors.newFixedThreadPool(24)

    for ((soundName, soundStartDate) <- soundsNameAndStartDate) {

      val soundUri = new URI(soundsPath + "/" + soundName)
      val soundId = soundName.split("_")(0)

      val sfc = SingleFileHandler(
        recordSizeInSec: Float,
        windowSize: Int,
        windowOverlap: Int,
        nfft: Int,
        lowFreqTOL: Option[Double],
        highFreqTOL: Option[Double],
        soundUri: URI,
        soundId: String,
        soundSamplingRate: Float,
        soundChannels: Int,
        soundSampleSizeInBits: Int,
        soundStartDate: String,
        resultsDestination: String
      )

      pool.execute(sfc)
    }

    pool.shutdown()
  }
}
