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

import os, sys
from time import time
from abc import ABC, abstractmethod


class Benchmark(ABC):
    VERSION = None

    def __init__(
        self, n_nodes, n_files, input_base_dir, output_base_dir
    ):
        self.run_command = None

        self.n_files = n_files
        self.n_nodes = n_nodes
        self.input_base_dir = input_base_dir
        self.output_base_dir = output_base_dir

        self.params = " {} {} {} {} ".format(self.n_nodes, self.n_files,
            self.input_base_dir, self.output_base_dir)

        self.duration = -1

    def run(self):
        print("Starting {} benchmark with {} files".format(self.VERSION, self.n_files))

        t_start = time()
        return_code = os.system(self.run_command)
        return_code = os.system("echo '{}'".format(self.run_command))
        print("")
        t_end = time()

        if return_code is not 0:
            sys.exit(1)

        self.duration = t_end - t_start

        print("Benchmark {} completed in {}s".format(self.VERSION, self.duration))

        return [
            self.VERSION,
            str(self.n_nodes),
            str(self.n_files),
            str(self.duration)
        ]

class SingleNodeBenchmark(Benchmark):
    def __init__(self, n_nodes, n_files, input_base_dir, output_base_dir):
        if n_nodes != 1:
            raise Exception(
                self.VERSION + " doesn't cannot scale out !"
            )
        super(SingleNodeBenchmark, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )

class FEBenchmarkRun(Benchmark):
    VERSION = "feature_engine_benchmark"
    SPARK_DEFAULT_PARAMS = [
        "--driver-memory 4G",
        "--executor-cores 3",
        "--executor-memory 5500M",
        "--class org.oceandataexplorer.engine.benchmark.SPM",
        "--conf spark.hadoop.mapreduce.input"\
            + ".fileinputformat.split.minsize=268435456"
    ]

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        spark_params=None
    ):
        super(FEBenchmarkRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )

        fe_jar_location = (
            " FeatureEngine-benchmark/target/"
            "scala-2.11/FeatureEngine-benchmark-assembly-0.1.jar "
        )

        executors_param = " --num-executors {} ".format(n_nodes * 17)

        self.run_command = "spark-submit "\
            + " ".join(FEBenchmarkRun.SPARK_DEFAULT_PARAMS + [executors_param])\
            + fe_jar_location + self.params


class PythonVanillaRun(SingleNodeBenchmark):
    VERSION = "python_vanilla"

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir
    ):
        super(PythonVanillaRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "cd python_benchmark_workflow && "
            "python3 spm_vanilla.py " + self.params
        )


class PythonNoBBRun(SingleNodeBenchmark):
    VERSION = "python_nobb"

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir
    ):
        super(PythonNoBBRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "cd python_benchmark_workflow && "
            "python3 spm_nobb.py " + self.params
        )

class MatlabVanillaRun(SingleNodeBenchmark):
    VERSION = "matlab_vanilla"

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir
    ):
        super(MatlabVanillaRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "cd Matlab-workflow/vanilla && "
            "/appli/ensta/matlab/R2016b/bin/matlab "
            "-nodisplay -nosplash -nodesktop "
            "-r \"spm {}; exit\" ".format(self.params)
        )

class BenchmarkManager(object):
    RUNS = {
        1: [1, 2, 3],
        2: [1, 5],
    }

    def __init__(
        self,
        n_nodes,
        input_base_dir,
        output_base_dir,
        runs=None
    ):
        self.n_nodes = n_nodes
        self.input_base_dir = input_base_dir
        self.output_base_dir = output_base_dir
        self.benchmarks = []
        self.results = []

        self.init_benchmarks(BenchmarkManager.RUNS if (runs == None) else runs)

    def init_benchmarks(self, runs):
        for n_files in runs[self.n_nodes]:
            if self.n_nodes is 1:
                self.benchmarks.append(PythonVanillaRun(
                    self.n_nodes, n_files,
                    self.input_base_dir, self.output_base_dir))

                self.benchmarks.append(PythonNoBBRun(
                    self.n_nodes, n_files,
                    self.input_base_dir, self.output_base_dir))

                self.benchmarks.append(MatlabVanillaRun(
                    self.n_nodes, n_files,
                    self.input_base_dir, self.output_base_dir))

            self.benchmarks.append(FEBenchmarkRun(
                self.n_nodes, n_files,
                self.input_base_dir, self.output_base_dir))

    def run_benchmarks(self):
        for benchmark in self.benchmarks:
            result = benchmark.run()
            self.results.append(result)

    def save_as_csv(self, result_file_path):
        csv_string = "\n".join([",".join(result) for result in self.results])
        f = open(result_file_path, "w")
        f.write(csv_string)
        f.close()


if __name__ == "__main__":
    if (len(sys.argv) < 4):
        print("nodes indir outdir")
        exit(1)

    n_nodes = int(sys.argv[1])
    input_base_dir = sys.argv[2]
    output_base_dir = sys.argv[3]

    spark_params = [
        "--class org.oceandataexplorer.engine.benchmark.SPM"]

    benchmarks = BenchmarkManager(n_nodes, input_base_dir, output_base_dir)

    benchmarks.run_benchmarks()

    benchmarks.save_as_csv(
        "/home/datawork-alloha-ode/results/benchmark_durations_{}node.csv".format(n_nodes))
