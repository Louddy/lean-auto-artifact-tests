# Artifact for Lean-auto

#133 Lean-auto: An Interface between Lean 4 and Automated Theorem Provers

We claim the reusable badge for `lean-auto`.

Note that the license file in this artifact is only for the test scripts, not for `lean-auto` and the dependencies of `lean-auto`. For `lean-auto` and its dependencies, their license files are in their individual folders in the docker image.

## Artifact Requirements

The experiments consist of six tasks. Tasks (a)-(e) run different types of tools on our benchmark, which consists of 149142 Mathlib4 theorems.
* a. Evaluating `lean-auto + CVC5`
* b. Evaluating `lean-auto + Duper (Native)`
* c. Evaluating `lean-auto + Z3`
* d. Evaluating `lean-auto + Zipperposition`
* e. Evaluating existing tactics (`rfl`, `simp_all`, `aesop`)
* f. Analyze experimental results

The experiment script allows you to specify the number of Lean 4 processes to run in parallel during the evaluation. If you want to run the experiment script with $k$ parallel Lean 4 processes, you will need $4k$ GB of RAM.  
In our evaluation, the experiment is run on Amazon EC2 instance type `c5ad.16xlarge` with 64 cores, 128 GB RAM and clock frequency 3.3 GHz, using 32 parallel Lean 4 processes. Here are the approximate times that each task took:
* a. 4 hours
* b. 5 hours
* c. 3.5 hours
* d. 4 hours
* e. 2 hours
* f. 2.5 minutes

It is possible to replicate a subset of the results with modest resource and time limits, see the **Getting Started** section.

## Structure and Content

The most relevant components of the artifact are inside the `/home` directory of the docker image
* `lean-auto`: The cloned github repo of Lean-auto
* `lean_hammertest_lw`: Lean 4 code providing support for evaluating `lean-auto` and other tools on Mathlib4
* `test_scripts`: Bash scripts used to evaluate `lean-auto` and other tools on Mathlib4
* `result_analysis`: Python scripts used to analyze results produced by `test_scripts/all_experiments.sh`
* Dependencies
  * `cvc5`
  * `z3`
  * Scripts used to install `zipperposition`
  * Cloned github repo of `duper` (a Lean 4 repo imported by `lean-auto`)

  `cvc5`, `z3` and `zipperposition` are already installed in the docker image. Note that in `bash`, you need to run `eval $(opam env)` before you can access `zipperposition`


## Getting Started

First, load the docker image `lean-auto-artifact` from the .tar archive (docker may require `sudo` root privileges):
```bash
docker load < lean-auto-artifact.tar
```

Run the container with
```bash
docker run --init -d lean-auto-artifact tail -f /dev/null
```

This command starts a docker container and leaves the container running in the background. Docker will assign a random name to the container, which you can view using ``docker container list``. Due to unknown issues, there could be up to around 80 zombie solver processes per Lean 4 process at certain points during the evaluation of `lean-auto + CVC5`, `lean-auto + Z3` and `lean-auto + Zipperposition`. The ``--init`` option makes sure that these zombie processes are properly reaped when the Lean 4 process exits.

To attach to the container, use
```bash
docker exec -it <container_name> bash
```

This command attaches to `<container_name>` and places you in a bash environment, where you can inspect the source code or run the experiments. To run the full experiment, use
```bash
/home/test_scripts/all_experiments.sh <n_procs> /home/lean_hammertest_lw
```
where `<n_procs>` is the number of Lean 4 processes to run in parallel.

To run a subset of the experiments, use
```bash
/home/test_scripts/all_experiments.sh <n_procs> /home/lean_hammertest_lw <n_mods>
```
This will run evaluation on `<n_mods>` randomly selected modules from the ``5518`` Mathlib4 modules that are used in the full experiment.

To detect any technical difficulties during the smoke test phase, use
```bash
/home/test_scripts/all_experiments.sh <n_procs> /home/lean_hammertest_lw 4
```

If finished successfully, the evaluation script should print

```
Experiment starts: <timestamp>
...
Result Analysis done: <timestamp>
```

The result of the experiments are located in `/home/lean_hammertest_lw/allResults`, and the analysis outputs are located in `/home/result_analysis`. You can use ``docker cp <container_name>:<path> <host_path>`` to copy files from the container to the host machine.

You can exit the container by typing `exit`. After exiting the container, you can remove the container using ``docker rm <container_name>``. Note that you'll need ``docker container list -a`` to view the names of exited containers.


## Reusable badge
* Replication of results of the paper: By running the full experiment, you will be able to reproduce the results in the `Experiments` section of the paper. The script `test_scripts/all_experiments.sh` runs the experiments and calls the analysis script `result_analysis/cumultime.py`, which prints out the total number of theorems:
  ```
  Total: <num>
  ```
  the number of theorems solved and the average solving time for each solver (including VBSes):
  ```
  Solved by <solver_name>: <num> | Avg time : <time>
  ```
  and unique solves across `rfl`, `simp_all vbs`, `aesop vbs` and `lean-auto vbs`:
  ```
  Unique solves by <solver_name>: <num>
  ```
  The analysis script also outputs the `#Solved - Cumulative Time` plot and `#Solved - Time` plot (both are present in the `Experiments` section of the paper) in pdf format.
* Correctness of the artifact: All existing tools and the `lean-auto + duper` configuration generates Lean 4 proofs, and these proofs are checked by the Lean 4 kernel. For `lean-auto + z3/cvc5/zipperposition`, they do not generate Lean 4 proofs. However, since the source code of solver-specific translations is short, and the translation procedures behave correctly on test cases in `lean-auto/Test/Test_Regression.lean`, we're relatively confident about their correctness.
* Source code: `lean-auto` is open source on `https://github.com/leanprover-community/lean-auto`. The cloned `lean-auto` repo can be found in the `/home/lean-auto` directory of the docker image. The dockerfile and scripts used to build the docker image is on `https://github.com/PratherConid/lean-auto-artifact`.
* Usage beyond the paper: In general, ``lean-auto`` can be used to automate or partly automate proofs of Lean 4 theorems. To use ``lean-auto``, include ``lean-auto`` as a dependency in your Lean 4 project. For details on how to set up Lean 4 projects, refer to `https://lean-lang.org/Lean 4/doc/quickstart.html` and `https://lean-lang.org/Lean 4/doc/setup.html`.
* Building the artifact on a different environment: The dockerfile and scripts used to build the docker image is on `https://github.com/PratherConid/lean-auto-artifact`. To build the artifact outside of docker, follow the shell commands in the dockerfile.