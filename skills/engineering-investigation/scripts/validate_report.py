#!/usr/bin/env python3
"""Validate the structural evidence contract of an investigation report."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


SECTION_GROUPS = {
    "decision summary": ("decision summary", "bottom line", "one-paragraph overview"),
    "plain-language summary": (
        "plain-language summary",
        "what happened and what is proposed",
        "what happened",
    ),
    "system flow and glossary": ("system flow and glossary", "system flow", "architecture and glossary"),
    "population and scope": ("population and scope", "scope and population", "impact and scope"),
    "claim ledger": ("claim ledger", "finding ledger"),
    "open questions": (
        "open questions",
        "residual questions",
        "residual questions that require an owner or protected evidence",
    ),
    "ordered next checks": ("ordered next checks", "ordered actions"),
    "likely stakeholder questions": ("likely stakeholder questions",),
    "draft stakeholder handoff": (
        "draft stakeholder handoff",
        "draft handoff",
    ),
    "source index": ("source index", "sources", "core sources"),
}

FINDING_HEADING = re.compile(r"^###\s+(F\d+)\s+-\s+(.+?)\s*$", re.MULTILINE)
STATUS = re.compile(r"^\*\*Status:\s*(.+?)\*\*\s*$", re.MULTILINE | re.IGNORECASE)
ALLOWED_STATUS = re.compile(r"\b(Proven|Derived|Hypothesis|Unknown)\b", re.IGNORECASE)
PLACEHOLDER = re.compile(r"\[(?:NEEDS(?:\s+[^\]]*)?|LINK)\]|\bTODO\s*:", re.IGNORECASE)
MARKDOWN_LINK = re.compile(r"\[[^\]]+\]\(https?://[^)]+\)")

FINDING_FIELDS = {
    "Evidence": r"Evidence",
    "Supports": r"Supports",
    "Does not prove": r"Does not prove(?:\s+by itself)?",
    "Could be disproved by": r"Could be disproved by",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="Treat warnings as validation errors.")
    parser.add_argument("report", type=Path, help="Markdown investigation report to validate.")
    return parser.parse_args()


def normalize_heading(value: str) -> str:
    value = re.sub(r"[`*_]", "", value).strip().lower()
    return re.sub(r"\s+", " ", value)


def h2_sections(text: str) -> dict[str, str]:
    matches = list(re.finditer(r"^##\s+(.+?)\s*$", text, re.MULTILINE))
    sections: dict[str, str] = {}
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        sections[normalize_heading(match.group(1))] = text[match.end() : end].strip()
    return sections


def section_for(sections: dict[str, str], aliases: tuple[str, ...]) -> str | None:
    normalized_aliases = tuple(normalize_heading(alias) for alias in aliases)
    for heading, body in sections.items():
        if any(heading == alias or heading.startswith(alias + " ") for alias in normalized_aliases):
            return body
    return None


def validate(text: str) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    sections = h2_sections(text)

    for label, aliases in SECTION_GROUPS.items():
        body = section_for(sections, aliases)
        if body is None:
            errors.append(f"missing required section: {label}")
        elif not body.strip():
            errors.append(f"required section is empty: {label}")

    findings = list(FINDING_HEADING.finditer(text))
    if not findings:
        errors.append("claim ledger must contain at least one '### F# - claim' finding")

    seen: set[str] = set()
    for index, finding in enumerate(findings):
        finding_id = finding.group(1).upper()
        if finding_id in seen:
            errors.append(f"duplicate finding ID {finding_id}")
        seen.add(finding_id)

        next_h2 = re.search(r"^##\s+", text[finding.end() :], re.MULTILINE)
        next_finding_start = findings[index + 1].start() if index + 1 < len(findings) else len(text)
        section_end = finding.end() + next_h2.start() if next_h2 else len(text)
        body = text[finding.end() : min(next_finding_start, section_end)]

        status_match = STATUS.search(body)
        if not status_match:
            errors.append(f"{finding_id}: missing '**Status: ...**'")
        elif not ALLOWED_STATUS.search(status_match.group(1)):
            errors.append(f"{finding_id}: status must include Proven, Derived, Hypothesis, or Unknown")

        for field, field_pattern in FINDING_FIELDS.items():
            if not re.search(rf"^-\s+{field_pattern}:\s*\S", body, re.MULTILINE | re.IGNORECASE):
                errors.append(f"{finding_id}: missing or empty '{field}:' field")

    scope = section_for(sections, SECTION_GROUPS["population and scope"])
    if scope is not None:
        if "|" not in scope or not re.search(r"\bwindow\b", scope, re.IGNORECASE):
            warnings.append("population and scope should include a table with a time window")
        if not re.search(r"\bunit\b", scope, re.IGNORECASE):
            warnings.append("population and scope should name the unit for quantitative claims")

    source_index = section_for(sections, SECTION_GROUPS["source index"])
    if source_index is not None and not MARKDOWN_LINK.search(source_index):
        warnings.append("source index contains no retrievable Markdown link")

    for match in PLACEHOLDER.finditer(text):
        line_number = text.count("\n", 0, match.start()) + 1
        warnings.append(f"line {line_number}: unresolved placeholder {match.group(0)}")

    return errors, warnings


def main() -> int:
    args = parse_args()
    try:
        text = args.report.read_text(encoding="utf-8")
    except OSError as exc:
        print(f"ERROR: cannot read {args.report}: {exc}")
        return 1

    errors, warnings = validate(text)
    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}")

    if errors or (args.strict and warnings):
        print(
            f"FAIL: {len(errors)} error(s), {len(warnings)} warning(s)"
            + ("; strict mode treats warnings as failures" if args.strict and warnings else "")
        )
        return 1

    print(f"PASS: {args.report} ({len(warnings)} warning(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
