"""Assemble the consultancy report from docs/*.md and print it to PDF with headless Chrome.

Run from the project root:  .venv/bin/python reports/build_report.py
Outputs: reports/final_report.html and reports/final_report.pdf

The Markdown files in docs/ are the single source of truth; this script only concatenates
them in task order, converts them to HTML and prints. Edit the Markdown, not the output.
"""

import re
import subprocess
import sys
from datetime import date
from pathlib import Path

import markdown

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
OUT_HTML = ROOT / "reports" / "final_report.html"
OUT_PDF = ROOT / "reports" / "final_report.pdf"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

SECTIONS = [
    "report_front.md",
    "task1_task2_industry_and_research.md",
    "task3_descriptive_analysis.md",
    "task4_statistical_inference.md",
    "task5_predictive_modelling.md",
    "task6_experimental_design.md",
    "task7_pca.md",
    "task8_bayesian.md",
    "task9_time_series.md",
    "task10_innovation_proposal.md",
    "task11_expert_validation.md",
    "task12_recommendations.md",
]

CSS = """
@page { size: A4; margin: 18mm 16mm 18mm 16mm; }
:root { --ink: #1f2933; --muted: #5f6b7a; --rule: #d5dbe3; --accent: #1d4e89; --tint: #f3f6fa; }
html { font-size: 10pt; }
body { font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; color: var(--ink); line-height: 1.45;
       background: #fff; margin: 0; }
h1 { font-size: 19pt; color: var(--accent); margin: 0 0 10pt; padding-bottom: 5pt; border-bottom: 2px solid var(--accent);
     page-break-before: always; break-before: page; }
h2 { font-size: 13pt; color: var(--accent); margin: 16pt 0 6pt; break-after: avoid; }
h3 { font-size: 11pt; margin: 12pt 0 4pt; break-after: avoid; }
p, li { margin: 0 0 5pt; }
ul, ol { padding-left: 16pt; margin: 0 0 6pt; }
table { border-collapse: collapse; width: 100%; margin: 6pt 0 10pt; font-size: 8.4pt; break-inside: auto; }
thead { display: table-header-group; }
tr { break-inside: avoid; }
th { background: var(--tint); text-align: left; font-weight: 600; }
th, td { border: 1px solid var(--rule); padding: 3pt 5pt; vertical-align: top; }
blockquote { margin: 8pt 0; padding: 6pt 10pt; background: #fff6e5; border-left: 4px solid #d98e04; }
blockquote p { margin: 0; }
img { display: block; max-width: 100%; max-height: 105mm; margin: 8pt auto 2pt; break-inside: avoid; }
p > em:only-child { display: block; font-size: 8.5pt; color: var(--muted); text-align: center; }
code { font-family: Menlo, Consolas, monospace; font-size: 8.5pt; background: var(--tint); padding: 0 2pt; border-radius: 2pt; }
a { color: var(--accent); text-decoration: none; word-break: break-word; }
.title-page { height: 250mm; display: flex; flex-direction: column; justify-content: center; }
.title-page .kicker { font-size: 10pt; letter-spacing: 1.5pt; text-transform: uppercase; color: var(--muted); }
.title-page .title { font-size: 28pt; font-weight: 700; color: var(--accent); line-height: 1.15; margin: 10pt 0; }
.title-page .subtitle { font-size: 13pt; color: var(--ink); margin-bottom: 30pt; }
.title-page .meta { font-size: 10pt; color: var(--muted); border-top: 1px solid var(--rule); padding-top: 10pt; }
.toc h1 { page-break-before: always; }
.toc ol { list-style: none; padding-left: 0; }
.toc li { margin: 2pt 0; }
.toc li.l2 { padding-left: 14pt; font-size: 9pt; color: var(--muted); }
"""


def load(name):
    text = (DOCS / name).read_text(encoding="utf-8")
    text = re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S)              # YAML front matter
    text = text.replace("](../reports/figures/", "](figures/")              # docs/ -> reports/ paths
    text = re.sub(r"^(\s*)- \[ \]", r"\1- ☐", text, flags=re.M)             # task-list checkboxes
    text = re.sub(r"^(\s*)- \[x\]", r"\1- ☑", text, flags=re.M)
    return separate_lists(text)


LIST_ITEM = re.compile(r"^(\* |- |\d+\. )")


def separate_lists(text):
    """Python-Markdown needs a blank line before a list that follows a paragraph line."""
    out = []
    for line in text.split("\n"):
        prev = out[-1] if out else ""
        if (LIST_ITEM.match(line) and prev.strip() and not prev.startswith((" ", "\t", "|", "#"))
                and not LIST_ITEM.match(prev)):
            out.append("")
        out.append(line)
    return "\n".join(out)


def build_html():
    md = markdown.Markdown(extensions=["tables", "toc", "smarty", "sane_lists", "attr_list"],
                           extension_configs={"toc": {"toc_depth": "1-2"}})
    body = md.convert("\n\n".join(load(s) for s in SECTIONS))

    toc_items = []
    for tok in md.toc_tokens:
        toc_items.append(f'<li><a href="#{tok["id"]}">{tok["name"]}</a></li>')
        if tok["name"].startswith("Task"):
            for child in tok["children"]:
                if child["name"].startswith("References"):
                    continue
                toc_items.append(f'<li class="l2"><a href="#{child["id"]}">{child["name"]}</a></li>')

    title = f"""
<section class="title-page">
  <div class="kicker">IT3081 Statistical Modelling · Group Consultancy Report</div>
  <div class="title">Customer Repurchase and Value Prediction for a UK Online Retailer</div>
  <div class="subtitle">Predicting which customers will return, what they are worth, and how to spend the retention budget</div>
  <div class="meta">Client scenario: a UK online giftware wholesaler · Dataset: UCI Online Retail II (2009–2011)<br>
  Prepared {date.today():%d %B %Y} · Task 11 (expert validation) pending</div>
</section>"""
    toc = f'<section class="toc"><h1>Contents</h1><ol>{"".join(toc_items)}</ol></section>'
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8">'
            f'<meta name="viewport" content="width=device-width, initial-scale=1">'
            f'<title>Customer Repurchase Consultancy Report</title><style>{CSS}</style></head>'
            f'<body>{title}{toc}{body}</body></html>')


def main():
    OUT_HTML.write_text(build_html(), encoding="utf-8")
    print("Wrote", OUT_HTML.relative_to(ROOT))
    if "--html-only" in sys.argv:
        return
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--print-to-pdf={OUT_PDF}", OUT_HTML.as_uri()],
                   check=True, capture_output=True)
    print("Wrote", OUT_PDF.relative_to(ROOT))


if __name__ == "__main__":
    main()
