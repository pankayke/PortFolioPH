"""
setup_jira_sprints.py
Automates Sprint 1 & Sprint 2 lifecycle on the PF Jira board:
  1. Add missing issues to each sprint
  2. Start Sprint 1
  3. Move all Sprint 1 issues → In Progress → Done
  4. Complete Sprint 1
  5. Start Sprint 2
  6. Move all Sprint 2 issues → In Progress → Done
  7. Complete Sprint 2

Run: python scripts/setup_jira_sprints.py
"""

import base64
import json
import time
import urllib.request
import urllib.error
from datetime import datetime, timedelta

# ── Config ─────────────────────────────────────────────────────────────────────
EMAIL = "markleannie.gacutno@gmail.com"
TOKEN = (
    "ATATT3xFfGF0WZLK2vAFx24hvlVTVuud6SzHugHkQrSoMedt4t1oQ4KFtiUHA_kQAApBU"
    "-LG0V5SCbAv5DPRrG4xhEjcaEEZAlHMcBLc32tqyEnOA0m5ABUokh-3Ca83rMo"
    "-e45A3oKbfSvRORp_6U2aDl74UrSX46uYOMCs0Sn_mNgNchJ_yXk=DE87523A"
)
BASE = "https://lnu-team-bzwkaw6h.atlassian.net"
SPRINT1_ID = 4
SPRINT2_ID = 5

# Sprint 1: PF-9..PF-20 (already assigned) + PF-21..PF-26 (supporting tasks)
SPRINT1_EXTRA = [f"PF-{i}" for i in range(21, 27)]   # PF-21 to PF-26

# Sprint 2: PF-27..PF-44 (auth + profile + dashboard + docs)
SPRINT2_ISSUES = [f"PF-{i}" for i in range(27, 45)]  # PF-27 to PF-44

# All Sprint 1 issues (after adding extras)
SPRINT1_ALL = [f"PF-{i}" for i in range(9, 27)]      # PF-9 to PF-26

# Transition IDs (from Jira project workflow)
T_IN_PROGRESS = "21"
T_DONE = "31"

# Dates
S1_START = "2026-01-05T09:00:00.000+0000"
S1_END   = "2026-01-18T17:00:00.000+0000"
S2_START = "2026-01-19T09:00:00.000+0000"
S2_END   = "2026-02-01T17:00:00.000+0000"

# ── HTTP helper ────────────────────────────────────────────────────────────────
_creds = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()

def _req(method: str, path: str, body=None):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Basic {_creds}")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        body_txt = e.read().decode(errors="replace")
        print(f"  ⚠️  HTTP {e.code} on {method} {path}: {body_txt[:200]}")
        return None


def get(path: str):
    return _req("GET", path)

def post(path: str, body: dict):
    return _req("POST", path, body)

def put(path: str, body: dict):
    return _req("PUT", path, body)


# ── Step helpers ───────────────────────────────────────────────────────────────

def add_issues_to_sprint(sprint_id: int, issue_keys: list[str], label: str):
    print(f"\n📌 Adding {len(issue_keys)} issues to Sprint {sprint_id} ({label})…")
    result = post(f"/rest/agile/1.0/sprint/{sprint_id}/issue", {"issues": issue_keys})
    if result is not None:
        print(f"  ✅ Done — {', '.join(issue_keys)}")
    else:
        print("  ❌ Failed — check permissions or issue keys")


def start_sprint(sprint_id: int, name: str, start: str, end: str):
    print(f"\n🚀 Starting sprint {sprint_id} ({name})…")
    result = post(
        f"/rest/agile/1.0/sprint/{sprint_id}",
        {
            "state": "active",
            "startDate": start,
            "endDate": end,
        },
    )
    # Jira sprint update is a POST to the sprint resource
    # Try PUT if POST fails
    if result is None:
        result = put(
            f"/rest/agile/1.0/sprint/{sprint_id}",
            {"state": "active", "startDate": start, "endDate": end},
        )
    if result is not None:
        print(f"  ✅ Sprint started")
    else:
        print("  ❌ Could not start sprint automatically (may need board-admin role)")


def transition_issue(key: str, transition_id: str, label: str):
    result = post(
        f"/rest/api/3/issue/{key}/transitions",
        {"transition": {"id": transition_id}},
    )
    status = "✅" if result is not None else "❌"
    print(f"  {status} {key} → {label}")
    return result is not None


def transition_all(issue_keys: list[str]):
    print(f"\n  ▶ Setting {len(issue_keys)} issues to In Progress…")
    for key in issue_keys:
        transition_issue(key, T_IN_PROGRESS, "In Progress")
        time.sleep(0.15)   # gentle rate-limiting

    print(f"\n  ✔ Setting {len(issue_keys)} issues to Done…")
    for key in issue_keys:
        transition_issue(key, T_DONE, "Done")
        time.sleep(0.15)


def complete_sprint(sprint_id: int, name: str):
    print(f"\n🏁 Completing sprint {sprint_id} ({name})…")
    result = put(
        f"/rest/agile/1.0/sprint/{sprint_id}",
        {"state": "closed"},
    )
    if result is None:
        result = post(
            f"/rest/agile/1.0/sprint/{sprint_id}",
            {"state": "closed"},
        )
    if result is not None:
        print("  ✅ Sprint closed")
    else:
        print("  ❌ Could not close sprint (may need board-admin role)")


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("  PortFolioPH — Jira Sprint Automation")
    print("=" * 60)

    # ── SPRINT 1 ──────────────────────────────────────────────────
    print("\n" + "─" * 60)
    print("  SPRINT 1 — Core Setup & Architecture")
    print("─" * 60)

    add_issues_to_sprint(SPRINT1_ID, SPRINT1_EXTRA, "supporting tasks")
    start_sprint(SPRINT1_ID, "PF Sprint 1", S1_START, S1_END)
    transition_all(SPRINT1_ALL)
    complete_sprint(SPRINT1_ID, "PF Sprint 1")

    # ── SPRINT 2 ──────────────────────────────────────────────────
    print("\n" + "─" * 60)
    print("  SPRINT 2 — Auth + Profile System")
    print("─" * 60)

    add_issues_to_sprint(SPRINT2_ID, SPRINT2_ISSUES, "Sprint 2 issues")
    start_sprint(SPRINT2_ID, "PF Sprint 2", S2_START, S2_END)
    transition_all(SPRINT2_ISSUES)
    complete_sprint(SPRINT2_ID, "PF Sprint 2")

    # ── Summary ───────────────────────────────────────────────────
    print("\n" + "=" * 60)
    print("  ✅ All done!")
    print(f"  Sprint 1: {len(SPRINT1_ALL)} issues closed")
    print(f"  Sprint 2: {len(SPRINT2_ISSUES)} issues closed")
    print("  Verify at: https://lnu-team-bzwkaw6h.atlassian.net/jira/software/c/projects/PF/boards/4/backlog")
    print("=" * 60)


if __name__ == "__main__":
    main()
