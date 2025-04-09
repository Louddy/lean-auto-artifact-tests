def parse_one_res(res : str):
    res, time, hb = res.split(" ")
    return (res, int(time), int(hb))

def parse_res_line(line : str):
    idx_str, line = line.split(" ", 1)
    idx = int(idx_str)
    res_str, name = line.split("] ", 1)
    res_str = res_str[2:]
    res_ss = res_str.split(", ")
    res_sss = [parse_one_res(res_s) for res_s in res_ss]
    return (idx, name, res_sss)

# `major = "tactic"` : Return a pair
#    * The list of the names of the theorems
#    * A map from tactic to the results associated with that tactic
# `major = "name"` : Return a pair
#    * The list of name of the tactics
#    * A list where each entry are the results associated with a name
# `filterBy` : If `filterBy` is an `int`, then treat `filterBy` as `testUnknownConstant`
#    and filter using it
def parse_all_result(fname : str, major : str = "tactic", filterBy = None
    ) -> tuple[list[str], list[tuple[int, str, list[tuple[str, int, int]]]]] | tuple[list[str], dict[str, list[tuple[str, int, int]]]]:
    with open(fname, "r", encoding='utf8') as f:
        content = f.read()
    lines = content.split("\n")
    tacs = lines[0].split(" ")
    res_lines = [line for line in lines[1:] if line != ""]
    parsed_lines = [parse_res_line(line) for line in res_lines]
    if filterBy is not None:
        assert isinstance(filterBy, int)
        tacs = tacs[:filterBy] + tacs[filterBy + 1:]
        parsed_lines = [(line[0], line[1], line[2][:filterBy] + line[2][filterBy + 1:]) for line in parsed_lines if line[2][filterBy][0] == 'S']
    if major == "name":
        return (tacs, parsed_lines)
    elif major == "tactic":
        names = [line[1] for line in parsed_lines]
        ret = {}
        for (tac, idx) in zip(tacs, range(0, len(tacs))):
            ret[tac] = [line[2][idx] for line in parsed_lines]
        return (names, ret)

# Input should be produced by `parse_all_result` with `major = "tactic"` and `filterBy`
#   set to the index of `testUnknownConstant`
def virtual_best_from_tactic_major_filtered(
        tac_major_result : tuple[list[str], dict[str, list[tuple[str, int, int]]]]
    ) -> list[tuple[str, int, int]]:
    vbest = []
    names, results = tac_major_result
    for i in range(len(names)):
        solved, time, hb = False, None, None
        for tac in results:
            n_res, n_time, n_hb = results[tac][i]
            if n_res == 'S':
                solved = True
                if time is None:
                    time = n_time
                    hb = n_hb
                else:
                    time = min(time, n_time)
                    hb = min(hb, n_hb)
        if solved:
            vbest.append(('S', time, hb))
        else:
            vbest.append(('E', 0, 0))
    return vbest

def filter_by_time_from_tactic_major(
        tac_major_result : tuple[list[str], dict[str, list[tuple[str, int, int]]]],
        time_ms : int
    ) -> list[tuple[str, int, int]]:
    _, results = tac_major_result
    ret = {}
    for tac in results:
        # `PT` stands for `posterior timeout`
        ret[tac] = [((res, time, hb) if time < time_ms else ('PT', time, hb)) for (res, time, hb) in results[tac]]
    return ret

def default_categorical_virtual_bests_from_tactic_major(
        tac_major_result : tuple[list[str], dict[str, list[tuple[str, int, int]]]],
    ):
    names, results = tac_major_result
    vbs = {}
    simp_results = {}
    for tac in ["simpAll", "simpAllWithPremises"]:
        simp_results[tac] = results[tac]
    simp_vbest = virtual_best_from_tactic_major_filtered((names, simp_results))
    aesop_results = {}
    for tac in ["aesop", "aesopWithPremises"]:
        aesop_results[tac] = results[tac]
    aesop_vbest = virtual_best_from_tactic_major_filtered((names, aesop_results))
    auto_results = {}
    for tac in ["autoNative", "autoZ3", "autoCVC5", "autoZipperpn"]:
        auto_results[tac] = results[tac]
    auto_vbest = virtual_best_from_tactic_major_filtered((names, auto_results))

    vbs = {}
    vbs['rfl'] = results['rfl']
    vbs['simp_all vbs'] = simp_vbest
    vbs['aesop vbs'] = aesop_vbest
    vbs['auto vbs'] = auto_vbest

    return vbs

def analyze_tactic_major_filtered(
        tac_major_result : tuple[list[str], dict[str, list[tuple[str, int, int]]]],
        print_unique_solves = True
    ):
    def successes(tac_results):
        return [i for i in tac_results if i[0] == 'S']
    
    names, results = tac_major_result
    vbest = virtual_best_from_tactic_major_filtered(tac_major_result)
    suc_vbest = successes(vbest)
    print('Total:', len(names))
    for tac in results:
        suc = successes(results[tac])
        avg_time = sum([res[1] for res in suc]) / len(suc)
        print('Solved by ' + tac + ':', len(suc), '| Avg time :', avg_time)
    print('Solved by vbest:', len(suc_vbest), '| Avg time :', sum([res[1] for res in suc_vbest]) / len(suc_vbest))
    if not print_unique_solves:
        return
    for tac in results:
        others = {}
        for tac_other in results:
            if tac_other != tac:
                others[tac_other] = results[tac_other]
        cumul_others = virtual_best_from_tactic_major_filtered((names, others))
        print('Unique solves by ' + tac + ':', len(suc_vbest) - len(successes(cumul_others)))

def default_analysis(fname : str):
    all_names, _ = parse_all_result(fname, major="tactic")
    print('#Unfiltered:', len(all_names))

    names, results = parse_all_result(fname, major="tactic", filterBy=0)
    results = filter_by_time_from_tactic_major((names, results), 10000)
    analyze_tactic_major_filtered((names, results), print_unique_solves=False)

    vbs = default_categorical_virtual_bests_from_tactic_major((names, results))
    analyze_tactic_major_filtered((names, vbs))

default_analysis(".\\allResults")