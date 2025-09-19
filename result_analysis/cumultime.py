import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import sys
from parse_all_result import *

def cumul_solving_time(df : dict[any, list], name: str, cumul : bool):
    fig, ax = plt.subplots(figsize=(6, 8))
    plt.rcParams["path.simplify_threshold"] = 1
    color_map = {
        'rfl' : 'orange',
        'simpAll' : 'lightgreen',
        'simpAllWithPremises' : 'green',
        'simp_all vbs' : 'cyan',
        'aesop' : 'lightblue',
        'aesopWithPremises' : 'blue',
        'aesop vbs' : 'darkblue',
        'aesopPSafeNew' : 'red',
        'aesopPSafeOld' : 'magenta',
        'aesopPUnsafeNew' : 'pink',
        'aesopPUnsafeOld' : 'purple',
        'saturateNewDAesop' : 'darkred',
        'saturateOldDAesop' : 'red',
        'saturateNewDAss' : 'magenta',
        'saturateOldDAss' : 'black',
        # 'autoCVC5' : 'pink',
        # 'autoNative' : 'red',
        # 'autoZ3' : 'magenta',
        # 'autoCVC5' : 'pink',
        # 'autoZipperpn' : 'purple',
        # 'auto vbs' : 'darkred',
        'overall vbs' : 'black'
    }
    label_map = {
        'rfl' : 'rfl',
        'simpAll' : 'simp_all - p',
        'simpAllWithPremises' : 'simp_all',
        'simp_all vbs' : 'simp_all VBS',
        'aesop' : 'Aesop - p',
        'aesopWithPremises' : 'Aesop',
        'aesop vbs' : 'Aesop VBS',
        'aesopPSafeNew' : 'Safe New',
        'aesopPSafeOld' : 'Safe Old',
        'aesopPUnsafeNew' : 'Unsafe New',
        'aesopPUnsafeOld' : 'Unsafe Old',
        'saturateNewDAesop' : 'Saturate New + Aesop',
        'saturateOldDAesop' : 'Saturate Old + Aesop',
        'saturateNewDAss' : 'Saturate New',
        'saturateOldDAss' : 'Saturate Old',
        'autoNative' : 'Lean-auto + Duper',
        # 'autoZ3' : 'Lean-auto + Z3',
        # 'autoCVC5' : 'Lean-auto + CVC5',
        # 'autoZipperpn' : 'Lean-auto + Zipper.',
        # 'auto vbs' : 'Lean-auto VBS',
        'overall vbs' : 'Overall VBS'
    }
    if cumul:
        for tac in df:
            # only consider rows where the problem was actually sat/unsat
            sorted = np.sort(df[tac])
            cumtime = [0]
            cumtime.extend(sorted)
            ax.plot(
                np.arange(0, len(df[tac]) + 1),
                np.cumsum(cumtime),
                # marker="o",
                color=mcolors.CSS4_COLORS[color_map[tac]],
                label=label_map[tac]
            )
    else:
        for tac in df:
            times, cnt = np.unique(df[tac], return_counts=True)
            times = np.concatenate([np.array([0]), times])
            cumcnt = np.cumsum(np.concatenate([np.array([0]), cnt]))
            ax.plot(
                cumcnt,
                times,
                # marker="o",
                color=mcolors.CSS4_COLORS[color_map[tac]],
                label=label_map[tac]
            )
        ax.set_ylim([1, None])
    ax.set_yscale('log')
    ax.set_xlabel("Problems solved")
    ax.set_ylabel("Time [ms] - " + name)
    ax.legend(loc="lower right", ncols=1, frameon=False)
    if cumul:
        plt.savefig("cumul_problems_cumul_" + name + ".pdf")
    else:
        plt.savefig("cumul_problems_noncumul_" + name + ".pdf")

def default_plot(fname):
    names, results = parse_all_result(fname, major="tactic", filterBy=0)
    results = filter_by_time_from_tactic_major((names, results), 10000)
    vbs = default_categorical_virtual_bests_from_tactic_major((names, results))
    results_with_vbs = {}
    for tac in results:
        results_with_vbs[tac] = results[tac]
    for tac in vbs:
        results_with_vbs[tac] = vbs[tac]

    df = {}
    for tac in results_with_vbs:
        df[tac] = [i[1] for i in results_with_vbs[tac] if i[0] == 'S']
    virtualBest = virtual_best_from_tactic_major_filtered((names, vbs))
    df["overall vbs"] = [time for (res, time, _) in virtualBest if res == 'S']
    cumul_solving_time(df, "non-cumulative", cumul=False)
    cumul_solving_time(df, "cumulative", cumul=True)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Illegal number of parameters")
        print("Usage: python3 <script_name> <path_to_result_file>")
        exit()
    path_to_result_file = sys.argv[1]
    default_plot(path_to_result_file)
    default_analysis(path_to_result_file)
