# SocSci-Repro-Bench

A benchmark for evaluating AI coding agents on computational reproducibility of social science research.

## Overview

SocSci-Repro-Bench consists of **221 reproduction tasks** drawn from **54 published social science papers** spanning four disciplines and twelve substantive domains. The benchmark is designed to evaluate whether AI coding agents can execute original research code and reproduce published findings when provided with data and replication materials.

Papers are selected such that their results are either **fully reproducible** with available materials or **demonstrably non-reproducible** due to missing data, thereby isolating agents' true reproduction capacity under feasible conditions.

## Repository Structure

```
SocSci-Repro-Bench/
├── benchmark/                    # Benchmark data and gold standards
│   ├── Papers_Tasks_Gold.json    # Gold-standard answers for all 221 tasks
│   ├── CSS_Bench_3Tasks.json     # Full benchmark (3 tasks per paper)
│   ├── CSS_Bench_1Task_WithoutAnswers.json  # Single-task version (no answers)
│   ├── CSS_Bench_Ideation.json   # Research question identification tasks
│   ├── SocSci-Bench_RQ_Gold.json # Gold-standard research questions
│   ├── papers_tasks/             # Per-paper task definitions (1–54)
│   └── original/                 # Original benchmark versions
├── results/                      # Evaluation results
│   ├── general/                  # Main accuracy and failure results
│   │   ├── cc/                   # Claude Code results (3 runs + PDF + sycophancy)
│   │   ├── cx/                   # Codex results (3 runs + PDF + sycophancy)
│   │   ├── stratify/             # Stratified analysis (by language, time cutoff)
│   │   ├── pdf_plots/            # PDF-condition comparison plots
│   │   └── syco_plots/           # Sycophancy-condition comparison plots
│   ├── paper_metadata/           # Metadata identification results
│   └── paper_rq/                 # Research question identification results
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

Each entry in `Papers_Tasks_Gold.json` contains:

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

## Citation

If you use this benchmark, please cite:

```
@article{alizadeh2025socscireprobench,
  title={SocSci-Repro-Bench: Evaluating AI Coding Agents on Computational Reproducibility of Social Science Research},
  author={Alizadeh, Meysam},
  year={2025}
}
```

## License

This work is licensed under [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/).
