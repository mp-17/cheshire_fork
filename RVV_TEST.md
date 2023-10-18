# RVV_TEST light-weight framework
> **_NOTE:_** This is not close to what a structured verification pipeline should look like, but it is an acceptable solution for the short time frames we have.

A set of utility make targets are defined to build and automate the tests for the extensions performed on Ara integrated in Cheshire and perform regression.

## Create a new test
Place a new test source file (.c) in `sw/tests/`. Only sources matching `rvv_test_*.c` are considered, built and run.
Definitions of assertion utilities are defined in `sw/tests/rvv_test.h`. Include this header in your sources.

## Run all tests
Run all tests in `sw/tests/` 2, 4 and 8 lanes configurations:
````console
$ make rvv-test-run-all
````
If you wish to run tests for just 2 and 4 lanes, override the `RVV_TEST_ARA_NR_LANES` variable:
````console
$ export RVV_TEST_ARA_NR_LANES="2 4"
````

Test reports are generated in `rvv_test_results/` for each test and lanes configuration.

Single test results are appended to `rvv_test_results/result_all.txt`.

## Run a single test
Select one test:
````console
$ ELF_ROOT=/scratch/vmaisto/cheshire_fork/sw/tests
$ export RVV_TEST=rvv_test_vstart_unit_stride
$ export RVV_TEST_ELF=${ELF_ROOT}/${RVV_TEST}.spm.elf
````

If you wish to launch QuestaSim GUI:
````console
$ export VSIM_ARGS=-gui
````

Set a commentary string for the test:
````console
$ export TEST_COMMENT="vadd avl = VLMAX"
````

Select lanes configuration, e.g.:
````console
$ export ARA_NR_LANES=4
````

## Launch test
````console
$ make rvv-test-run
$ make rvv-test-report
````

## Clean test environment
Unset these variables for subsequent runs:
````console
$ unset RVV_TEST RVV_TEST_ELF VSIM_ARGS ARA_NR_LANES TEST_COMMENT
````
 