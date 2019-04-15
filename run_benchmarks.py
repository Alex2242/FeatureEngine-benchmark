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
from subprocess import Popen
from time import time
from abc import ABC, abstractmethod


class Benchmark(ABC):
    VERSION = None
    PRINT_STR = "*" * 15 + "   {}   " + "*" * 15

    @staticmethod
    def print(s):
        print("")
        print(Benchmark.PRINT_STR.format(s))

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
        Benchmark.print("Starting {} benchmark with {} files".format(self.VERSION, self.n_files))
        print("Running command: {}\n\n".format(self.run_command))
        sys.stdout.flush()

        t_start = time()

        #return_code = os.system(self.run_command)
        #return_code = subprocess.call(self.run_command, shell=True)
        p = Popen(self.run_command, shell=True)
        p.wait()

        return_code = p.returncode
        print("")

        t_end = time()

        if (return_code != 0):
            print("Run failed\nused command:\n" + self.run_command)
            sys.exit(1)

        self.duration = t_end - t_start

        Benchmark.print("Benchmark {} with {} files, completed in {}s with code {}".format(
            self.VERSION, self.n_files, self.duration, return_code))

        print("\n\n")
        sys.stdout.flush()

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
        "--executor-cores 1",
        "--executor-memory 10G",
        "--conf spark.hadoop.mapreduce.input"\
            + ".fileinputformat.split.minsize=268435456"
    ]

    CLASS = "--class org.oceandataexplorer.engine.benchmark.SPM"

    FE_JAR_LOCATION = (
        " FeatureEngine-benchmark/target/"
        "scala-2.11/FeatureEngine-benchmark-assembly-0.1.jar "
    )

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        **kwargs
    ):
        super(FEBenchmarkRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )

        executors_param = " --num-executors {} ".format(
            n_nodes * kwargs.get("executors_per_node", 17)
        )

        spark_params = " ".join(
            kwargs.get("spark_params", self.SPARK_DEFAULT_PARAMS)
            + [executors_param]
            + [self.CLASS]
        )

        self.run_command = "spark-submit "\
            + spark_params\
            + self.FE_JAR_LOCATION + self.params

class FEBenchmarkMinRun(SingleNodeBenchmark):
    VERSION = "feature_engine_benchmark_min"

    SPARK_DEFAULT_PARAMS = [
        "--driver-memory 4G",
        "--executor-cores 1",
        "--num-executors 1"
        "--executor-memory 10G",
        "--class org.oceandataexplorer.engine.benchmark.SPM",
        "--conf spark.hadoop.mapreduce.input"\
            + ".fileinputformat.split.minsize=268435456"
    ]

    FE_JAR_LOCATION = (
        " FeatureEngine-benchmark/target/"
        "scala-2.11/FeatureEngine-benchmark-assembly-0.1.jar "
    )

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        spark_params=None,
        **kwargs
    ):
        super(FEBenchmarkMinRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )

        self.run_command = "spark-submit "\
            + " ".join(self.SPARK_DEFAULT_PARAMS)\
            + self.FE_JAR_LOCATION + self.params


class ScalaOnlyRun(SingleNodeBenchmark):
    # "scala_only" designates single threaded runs, equivalent to "scala_only_1"
    VERSION = "scala_only"
    # number of threads used is statically defined,
    # subclassing and overriding is the recommended way to change it
    N_THREADS = 1

    JAR_LOCATION = (
        " FeatureEngine-benchmark/target/"
        "scala-2.11/FeatureEngine-benchmark-assembly-0.1-scala_only.jar "
    )

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        **kwargs
    ):
        super(ScalaOnlyRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "java -Xms64g -Xmx100g -classpath " + self.JAR_LOCATION +
            "org.oceandataexplorer.engine.benchmark.SPMScalaOnly " + self.params +
            " {} ".format(self.N_THREADS)
        )


class PythonVanillaRun(SingleNodeBenchmark):
    VERSION = "python_vanilla"

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        **kwargs
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
        output_base_dir,
        **kwargs
    ):
        super(PythonNoBBRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "cd python_benchmark_workflow && "
            "python3 spm_nobb.py " + self.params
        )

class PythonMTRun(SingleNodeBenchmark):
    # "python_mt" designates single threaded runs, equivalent to "python_mt_1"
    VERSION = "python_mt"
    # number of threads used is statically defined,
    # subclassing and overriding is the recommended way to change it
    N_THREADS = 1

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        **kwargs
    ):
        super(PythonMTRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "cd python_benchmark_workflow && "
            "python3 spm_mt.py " + self.params + " {} ".format(self.N_THREADS)
        )

class PythonMTNoTolRun(SingleNodeBenchmark):
    VERSION = "python_mtnotol"

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        **kwargs
    ):
        super(PythonMTNoTolRun, self).__init__(
            n_nodes, n_files, input_base_dir, output_base_dir
        )
        self.run_command = (
            "cd python_benchmark_workflow && "
            "python3 spm_mtnotol.py " + self.params
        )

class MatlabVanillaRun(SingleNodeBenchmark):
    VERSION = "matlab_vanilla"

    def __init__(
        self,
        n_nodes,
        n_files,
        input_base_dir,
        output_base_dir,
        **kwargs
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
        1: [1, 5, 10],
        2: [1, 5, 10, 20]
    }

    BENCHMARK_CLASSES = [
        FEBenchmarkRun,
        PythonNoBBRun,
        PythonVanillaRun,
        MatlabVanillaRun
    ]

    def __init__(
        self,
        n_nodes,
        input_base_dir,
        output_base_dir,
        runs=None,
        benchmark_classes=None,
        extra_args=None
    ):
        self.n_nodes = n_nodes
        self.input_base_dir = input_base_dir
        self.output_base_dir = output_base_dir
        self.benchmarks = []
        self.results = []
        self.extra_args = extra_args if extra_args else {}

        self.init_benchmarks(
            runs if runs else self.RUNS,
            benchmark_classes if benchmark_classes else self.BENCHMARK_CLASSES
        )

    def init_benchmarks(self, runs, benchmark_classes):
        for n_files in runs[self.n_nodes]:
            for benchmark_class in benchmark_classes:
                if issubclass(benchmark_class, SingleNodeBenchmark) and self.n_nodes is not 1:
                    continue

                self.benchmarks.append(benchmark_class(
                    self.n_nodes,
                    n_files,
                    self.input_base_dir,
                    self.output_base_dir,
                    **self.extra_args
                ))

    def run_benchmarks(self):
        for benchmark in self.benchmarks:
            result = benchmark.run()
            self.results.append(result)

        print("\n" * 4)
        print("*" * 15 + "  Benchmarks completed  " + "*" * 15)

    def save_as_csv(self, result_file_path):
        csv_string = "\n".join([",".join(result) for result in self.results])
        f = open(result_file_path, "w")
        f.write(csv_string)
        f.close()

# temp classes

class FEBenchmarkRunWS(FEBenchmarkRun):
    """
    Computes Welch & SPL
    """
    VERSION = 'fe_welchspl'
    CLASS = "--class org.oceandataexplorer.engine.benchmark.SPMWS"

class FEBenchmarkRunWSLegacy(FEBenchmarkRun):
    """
    Computes Welch & SPL without sort or persist, old method
    """
    VERSION = 'fe_welchspl'
    CLASS = "--class org.oceandataexplorer.engine.benchmark.SPMWSLegacy"

def new_mt_run(MTBaseClass, n_threads):
    """
    Creates new multi-threaded benchmark classes given a number of threads
    """
    return type(
        MTBaseClass.version + "_{}".format(n_threads),
        (MTBaseClass,),
        {'N_THREADS': n_threads}
    )

if __name__ == "__main__":
    if (len(sys.argv) < 4):
        print("Invalid syntax\nUsage: python3 run_benchmark.py n_nodes indir outdir")
        exit(1)

    n_nodes = int(sys.argv[1])
    input_base_dir = sys.argv[2]
    output_base_dir = sys.argv[3]

    tag = 'notag'
    if (len(sys.argv) == 5):
        tag = sys.argv[4]

    runs = {
        1: [1, 3, 5]
    }

    # put the classes that should be run during benchmark here
    benchmarks = [
        ScalaOnlyRun
    ]

    # optionals arguments for benchmark
    extra_args = {
        'executors_per_node': 1
    }

    benchmarks = BenchmarkManager(
        n_nodes,
        input_base_dir,
        output_base_dir,
        runs,
        benchmarks,
        extra_args
    )

    benchmarks.run_benchmarks()

    benchmarks.save_as_csv(
        output_base_dir + "/times/benchmark_durations_{}node_{}.csv".format(n_nodes, tag))
