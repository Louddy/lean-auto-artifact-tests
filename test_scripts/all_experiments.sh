#!/bin/bash
# This script is only compatible with Mathlib4 29f9a66d622d9bab7f419120e22bb0d2598676ab, due to 'nonterminates'

decim_re='^[1-9][0-9]*$'
if ! ( [ "$#" -eq 2 ] || ( [ "$#" -eq 3 ] && [[ $3 =~ $decim_re ]] ) ) || ! [[ $1 =~ $decim_re ]]; then
  echo "Illegal number of parameters"
  echo "Usage: ./<script_name> <number_of_processors> <path_to_hammertest_repo> [<number_of_mathlib_modules_to_test>]"
  exit
fi

# Set up environment for Lean
source /root/.elan/env

# Remove results of previous experiments (if exists)
rm -rf $2/Eval*
rm -f $2/allResults

# Run evaluation using various tools
printf "Experiment starts: %(%s)T\n"
/home/test_scripts/autoCVC5.sh $@
printf "autoCVC5.sh done: %(%s)T\n"
/home/test_scripts/autoNative.sh $@
printf "autoNative.sh done: %(%s)T\n"
/home/test_scripts/autoZ3.sh $@
printf "autoZ3.sh done: %(%s)T\n"
/home/test_scripts/autoZipperpn.sh $@
printf "autoZipperpn.sh done: %(%s)T\n"
/home/test_scripts/tactics.sh $@
printf "tactics.sh done: %(%s)T\n"

# Gather results
cd $2 && lake env lean GatherResults.lean
printf "GatherResults.lean done: %(%s)T\n"
echo

# Analyze experimental results
echo "Analyzing results ..."
source /home/result-analysis-env/bin/activate
cd /home/result_analysis && python3 cumultime.py $2/allResults
printf "Result Analysis done: %(%s)T\n"