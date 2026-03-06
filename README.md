# SocSci-Repro-Bench

A benchmark for evaluating AI coding agents on computational reproducibility of social science research.

**Paper:** [Alizadeh, Mosleh, Gilardi, and Tucker (2026)](https://malizad.github.io/Alizadeh_et_al_Agents_Reproducibility.pdf)

## Overview

SocSci-Repro-Bench consists of **221 reproduction tasks** drawn from **54 published social science papers** spanning four disciplines and twelve substantive domains. The benchmark is designed to evaluate whether AI coding agents can execute original research code and reproduce published findings when provided with data and replication materials.

Papers are selected such that their results are either **fully reproducible** with available materials or **demonstrably non-reproducible** due to missing data, thereby isolating agents' true reproduction capacity under feasible conditions.

## Repository Structure

```
SocSci-Repro-Bench/
├── benchmark/                    # Benchmark data and gold standards
│   ├── SocSci_Repro_Bench.json   # Gold-standard answers for all 221 tasks
│   ├── SocSci_Repro_Bench_RQ.json # Gold-standard research questions
│   ├── SocSci_Repro_Bench_Metadata.json # Paper metadata (language, year, journal, etc.)
│   └── papers_tasks/             # Per-paper task definitions (1–54)
├── analysis/                     # R scripts for plots and statistical analysis
├── LICENSE                       # CC BY 4.0
└── README.md
```

## Key Results

| Metric | Claude Code | Codex |
|--------|-------------|-------|
| Task-level accuracy | 93.4% | 62.1% |
| Paper-level accuracy | 78.0% | 35.8% |
| Task failure rate | 0.0% | 17.8% |
| Paper failure rate | 0.0% | 27.0% |

Both agents were evaluated in controlled sandbox environments across three independent runs. Results are averaged across runs.

## Benchmark Tasks

Each paper contributes up to three reproduction tasks, each requiring the agent to:

1. Read and interpret the original analysis code
2. Set up the computational environment (install packages, resolve dependencies)
3. Execute the analysis pipeline
4. Extract and report specific quantitative results

Tasks cover analyses implemented in **R**, **Python**, and **Stata** across political science, sociology, economics, and psychology.

## Data Format

Each entry in `SocSci_Repro_Bench.json` contains:

```json
{
  "id": 1,
  "results": [
    {"Task 1 description": "gold answer"},
    {"Task 2 description": "gold answer"},
    {"Task 3 description": "gold answer"}
  ]
}
```

Tasks with gold answers of `"No Data"` or `"No Code or Data"` represent non-reproducible papers included to test whether agents correctly identify infeasible reproduction tasks.

## Replication Materials

The anonymized replication materials for all 54 papers (data files and analysis scripts) are available on the [Harvard Dataverse](https://dataverse.harvard.edu/dataverse/meysam_alizadeh).

## Citation

If you use this benchmark, please cite:

```
@article{alizadeh2026socscireprobench,
  title={Evaluating AI Coding Agents in Social Science Reproducibility},
  author={Alizadeh, Meysam and Mosleh, Mohsen and Gilardi, Fabrizio and Tucker, Joshua},
  year={2026},
  url={https://malizad.github.io/Alizadeh_et_al_Agents_Reproducibility.pdf}
}
```

## License

This work is licensed under [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/).
