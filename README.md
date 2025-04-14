**TODO:** License

# Artifact for Lean-auto

#133 Lean-auto: An Interface between Lean 4 and Automated Theorem Provers

**TODO**: Indicate which badges you claim for your artifact.
* If you claim an available badge, it is sufficient to upload your Docker or VM image to a repository that provides a DOI (e.g. Zenodo, figshare, or Dryad) and use this DOI link in your artifact submission.
* If you claim a functional or reusable badge, provide justification in the corresponding sections below. Note that an artifact that claims a reusable badge must also fulfil the criteria for the functional badge, in which case only the reusable badge will be awarded.


## Artifact Requirements

The experiments consist of six tasks. Task (a)-(e) runs different types of tools on our benchmark, which consists of 149142 Mathlib4 theorems.
* a. Evaluating lean-auto + CVC5
* b. Evaluating lean-auto + Duper(Native)
* c. Evaluating lean-auto + Z3
* d. Evaluating lean-auto + Zipperposition
* e. Evaluating existing tactics (rfl, simp_all, aesop)
* f. Analyze experimental results

The experiment script allows you to specify the number of Lean4 processes to run in parallel during the evaluation. If you want to run the experiment script with $k$ parallel Lean processes, you will need $4k$ GB of RAM.  
In our evaluation, the experiment is run on Amazon EC2 instance type `c5ad.16xlarge` with 64 cores, 128 GB RAM and clock frequency 3.3 GHz, using 32 parallel Lean4 processes. Here are the approximate times that each task took:
* a. 4 hours
* b. 5 hours
* c. 3.5 hours
* d. 4 hours
* e. 2 hours
* f. 2.5 minutes

It is possible to replicate a subset of the results with most resource and time limits, see the **Getting Started** section.

## Structure and Content

The most relevant components of the artifact are inside the `/home` directory of the docker container
* `lean-auto`: The cloned github repo of Lean-auto
* `lean_hammertest_lw`: Lean4 code providing support for evaluating `lean-auto` and other tools on Mathlib4
* `test_scripts`: Bash scripts used to evaluate `lean-auto` and other tools on Mathlib4
* `result_analysis`: Python scripts used to analyze results produced by `test_scripts/all_experiments.sh`
* Dependencies
  * `cvc5`
  * `z3`
  * Scripts used to install `zipperposition`
  * Cloned github repo of `duper` (a Lean4 repo imported by `lean-auto`)

  `cvc5`, `z3` and `zipperposition` are already installed in the docker container. Note that in `bash`, you need to run `eval $(opam env)` before you can access `zipperposition`


## Getting Started

First, download the docker image `indprinciples/lean-auto-artifact` (you might need `sudo` for `docker`):
```
docker pull indprinciples/lean-auto-artifact
```

Run the container with
```
docker run --init -d indprinciples/lean-auto-artifact tail -f /dev/null
```

This command starts a docker container and leaves the container running in the background. Docker will assign a random name to the container, which you can view using ``docker container list``. Due to unknown issues, there could be up to around 80 zombie solver processes per Lean4 process at certain points during the evaluation of `lean-auto + CVC5`, `lean-auto + Z3` and `lean-auto + Zipperposition`. The ``--init`` option makes sure that these zombie processes are properly reaped when the Lean4 process exits.

To attach to the container, use
```
docker exec -it <container_name> bash
```

This command attaches to `<container_name>` and places you in a bash environment, where you can inspect the source code or run the experiments. To run the full experiment, use
```
/home/test_scripts/all_experiments.sh <n_procs> /home/lean_hammertest_lw
```
where `<n_procs>` is the number of Lean4 processes to run in parallel.

To run a subset of the experiments, use
```
/home/test_scripts/all_experiments.sh <n_procs> /home/lean_hammertest_lw <n_mods>
```
This will run evaluation on `<n_mods>` randomly selected modules from the ``5518`` Mathlib4 modules that are used in the full experiment.

To detect any technical difficulties during the smoke test phase, use
```
/home/test_scripts/all_experiments.sh <n_procs> /home/lean_hammertest_lw 1
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
* Correctness of the artifact: All existing tools and the `lean-auto + duper` configuration generates Lean4 proofs, and these proofs are checked by the Lean4 kernel. For `lean-auto + z3/cvc5/zipperposition`, they do not generate Lean4 proofs. However, since the source code of solver-specific translations is short, and the translation procedures behave correctly on test cases in `lean-auto/Test/Test_Regression.lean`, we're relatively confident about their correctness.
* Source code: `lean-auto` is open source on `https://github.com/leanprover-community/lean-auto`. The cloned `lean-auto` repo can be found in the `/home/lean-auto` directory of the artifact. The dockerfile and scripts used to build the docker image is on `https://github.com/PratherConid/lean-auto-artifact`.
* Usage beyond the paper: In general, ``lean-auto`` can be used to automate or partly automate proofs of Lean4 theorems. To use ``lean-auto``, include ``lean-auto`` as a dependency in your Lean4 project.

**TODO:** If you claim a reusable badge for the artifact:

* Make sure your artifact has a license which allows repurposing and reuse, and is easy to use.
* Make sure that all dependencies and used libraries are well-documented and up to date.
* Explain in sufficient detail how the artifact can be used beyond the paper.
* If the artifact is not open source, provide documented interfaces for extensions.
* Explain how the artifact can be used in a different environment, e.g. built on another system, used outside of the Docker or VM image, etc.
