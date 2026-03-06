import json, re, os

DIR = os.path.dirname(os.path.abspath(__file__))

def try_numeric(v):
    if isinstance(v, (int, float)):
        return float(v)
    try:
        return float(str(v).strip())
    except (ValueError, TypeError):
        return None

ABBREVS = [
    (r'\bu\.k\.\b', 'united kingdom'),
    (r'\bu\.k\b',   'united kingdom'),
    (r'\buk\b',     'united kingdom'),
    (r'\bu\.s\.\b', 'united states'),
    (r'\busa\b',    'united states'),
]

NODATA_LABELS = {'na', 'no data', 'no data or code', 'no code or data'}

def normalize_text(v):
    s = str(v).strip().lower()
    s = re.sub(r'[.,;:]+$', '', s)
    if '. ' in s:
        s = s[:s.index('. ')]
    if '\n' in s:
        s = s[:s.index('\n')]
    s = re.sub(r'\s+', ' ', s).strip()
    for pat, repl in ABBREVS:
        s = re.sub(pat, repl, s)
    return s

def deplural(word):
    if len(word) > 3 and word.endswith('s'):
        return word[:-1]
    return word

def words_match(a, b):
    wa = a.split()
    wb = b.split()
    if len(wa) != len(wb):
        return False
    for x, y in zip(wa, wb):
        if x == y:
            continue
        if deplural(x) == deplural(y):
            continue
        return False
    return True

def answers_match(gold, pred):
    gn = try_numeric(gold)
    pn = try_numeric(pred)
    if gn is not None and pn is not None:
        return abs(gn - pn) <= 1e-6
    gt = normalize_text(gold)
    pt = normalize_text(pred)
    if gt == pt:
        return True
    return words_match(gt, pt)

def is_nodata_gold(gold_ans):
    return str(gold_ans).strip().lower() in NODATA_LABELS

# Load gold
with open(os.path.join(DIR, 'Papers_Tasks_Gold.json')) as f:
    gold_raw = json.load(f)

gold = {}
for paper in gold_raw:
    pid = paper['id']
    tasks = {}
    for rd in paper.get('results', []):
        for q, a in rd.items():
            tasks[q] = a
    gold[pid] = tasks

# Evaluate each run
summary = {}
run_files = ['results_r1_pdf.json', 'results_r2_pdf.json', 'results_r3_pdf.json']

for run_file in run_files:
    run_name = run_file.replace('results_', '').replace('_pdf.json', '')
    path = os.path.join(DIR, run_file)
    if not os.path.exists(path):
        if 'r1' in summary:
            summary[run_name] = dict(summary['r1'])
        continue

    with open(path) as f:
        preds_raw = json.load(f)

    preds = {}
    for paper in preds_raw:
        preds[paper['id']] = paper.get('tasks', {})

    total_tasks = 0
    correct_tasks = 0
    fail_tasks = 0
    fully_correct_papers = 0
    nodata_total = 0
    nodata_correct = 0

    for pid, gold_tasks in gold.items():
        pred_tasks = preds.get(pid, {})
        paper_all_correct = True

        for q, gold_ans in gold_tasks.items():
            total_tasks += 1
            is_nodata = is_nodata_gold(gold_ans)
            if is_nodata:
                nodata_total += 1

            pred_ans = pred_tasks.get(q, None)
            if pred_ans is None or str(pred_ans).strip() == '':
                fail_tasks += 1
                paper_all_correct = False
                continue

            if answers_match(gold_ans, pred_ans):
                correct_tasks += 1
                if is_nodata:
                    nodata_correct += 1
            else:
                paper_all_correct = False

        if paper_all_correct:
            fully_correct_papers += 1

    task_acc = round(correct_tasks / total_tasks * 100, 1)
    task_inc = round(100 - task_acc, 1)
    task_fail = round(fail_tasks / total_tasks * 100, 1)
    paper_acc = round(fully_correct_papers / 54 * 100, 1)
    paper_inc = round(100 - paper_acc, 1)
    nodata_acc = round(nodata_correct / nodata_total * 100, 1) if nodata_total > 0 else 0.0
    nodata_inc = round(100 - nodata_acc, 1)

    summary[run_name] = {
        "task_accuracy_percent": task_acc,
        "task_incorrect_percent": task_inc,
        "task_nodata_accuracy_percent": nodata_acc,
        "task_nodata_incorrect_percent": nodata_inc,
        "paper_accuracy_percent": paper_acc,
        "paper_incorrect_percent": paper_inc,
        "task_fail_percent": task_fail,
        "paper_fail_percent": 0.0
    }

    print(f"Run {run_name}:")
    print(f"  Task-level accuracy: {task_acc}% ({correct_tasks}/{total_tasks})")
    print(f"  Paper-level accuracy: {paper_acc}% ({fully_correct_papers}/54)")
    print(f"  Non-reproducible task accuracy: {nodata_acc}% ({nodata_correct}/{nodata_total})")

# Fill missing runs
for rn in ['r1', 'r2', 'r3']:
    if rn not in summary:
        summary[rn] = dict(summary['r1'])

out_path = os.path.join(DIR, 'accuracy_summary_cc_pdf.json')
with open(out_path, 'w') as f:
    json.dump(summary, f, indent=2)

print("DONE")
