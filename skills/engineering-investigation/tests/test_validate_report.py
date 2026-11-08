from __future__ import annotations

import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = SKILL_ROOT / "scripts" / "validate_report.py"


VALID_REPORT = textwrap.dedent(
    """\
    # Example investigation

    ## Decision summary
    The reviewer must decide whether to approve a guarded rollout.

    ## Plain-language summary
    A configuration mismatch skipped one required calculation.

    ## System flow and glossary
    Request -> configuration -> calculation -> stored result.

    ## Population and scope
    | Population | Window | Unit | Evidence | Limitation |
    |---|---|---|---|---|
    | Sample | 2026-09-01 to 2026-09-07 UTC | 42 requests | Query Q1 | Sample only |

    ## Claim ledger

    ### F1 - The mismatch exists in the sampled window
    **Status: Proven**
    - Evidence: Query Q1 returned 42 matching requests.
    - Supports: The mismatch occurred in the sampled population.
    - Does not prove: The mismatch affected every request.
    - Could be disproved by: Re-running Q1 with the recorded filters and finding no matches.

    ## Open questions
    None that block the stated decision.

    ## Ordered next checks
    1. Confirm the rollout owner and record the approval.

    ## Likely stakeholder questions
    - Is the impact population-wide? No; the evidence is sample-scoped.

    ## Draft stakeholder handoff
    The sampled mismatch is proven; population-wide impact is not.

    ## Source index
    - [Query Q1](https://example.invalid/query-q1) - captured 2026-09-08 UTC.
    """
)


def run_validator(report: str, *args: str) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as temp_dir:
        report_path = Path(temp_dir) / "report.md"
        report_path.write_text(report, encoding="utf-8")
        return subprocess.run(
            [sys.executable, str(VALIDATOR), *args, str(report_path)],
            capture_output=True,
            text=True,
            check=False,
        )


class ValidateReportTests(unittest.TestCase):
    def test_accepts_a_complete_evidence_report(self) -> None:
        result = run_validator(VALID_REPORT)

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("PASS", result.stdout)

    def test_rejects_a_claim_without_a_disproof_check(self) -> None:
        broken = VALID_REPORT.replace(
            "- Could be disproved by: Re-running Q1 with the recorded filters and finding no matches.\n",
            "",
        )

        result = run_validator(broken)

        self.assertEqual(result.returncode, 1)
        self.assertIn("F1", result.stdout)
        self.assertIn("Could be disproved by", result.stdout)

    def test_rejects_duplicate_finding_ids(self) -> None:
        duplicated = VALID_REPORT.replace(
            "## Open questions",
            "### F1 - A second claim reused the identifier\n"
            "**Status: Unknown**\n"
            "- Evidence: No authoritative record was available.\n"
            "- Supports: The answer remains open.\n"
            "- Does not prove: Either possible outcome.\n"
            "- Could be disproved by: An owner-provided authoritative record.\n\n"
            "## Open questions",
        )

        result = run_validator(duplicated)

        self.assertEqual(result.returncode, 1)
        self.assertIn("duplicate finding ID F1", result.stdout)

    def test_accepts_a_scoped_does_not_prove_label(self) -> None:
        scoped = VALID_REPORT.replace(
            "- Does not prove: The mismatch affected every request.",
            "- Does not prove by itself: The mismatch affected every request.",
        )

        result = run_validator(scoped)

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_placeholders_warn_normally_and_fail_in_strict_mode(self) -> None:
        draft = VALID_REPORT.replace(
            "The sampled mismatch is proven; population-wide impact is not.",
            "The sampled mismatch is proven. Report: [LINK]",
        )

        normal = run_validator(draft)
        strict = run_validator(draft, "--strict")

        self.assertEqual(normal.returncode, 0, normal.stdout + normal.stderr)
        self.assertIn("WARNING", normal.stdout)
        self.assertEqual(strict.returncode, 1)
        self.assertIn("unresolved placeholder", strict.stdout)


if __name__ == "__main__":
    unittest.main()
