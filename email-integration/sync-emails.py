#!/usr/bin/env python3
"""
Nemesis Project — Email to Notes Sync (Mock Test Version)
Tests routing logic before real connector integration
"""

import os
import sys
import re
import json
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Dict, Tuple

try:
    from fuzzywuzzy import fuzz
except ImportError:
    print("ERROR: fuzzywuzzy not installed. Run: pip install fuzzywuzzy python-Levenshtein")
    sys.exit(1)


class MockEmail:
    """Represents a mock email for testing"""

    def __init__(
        self, sender: str, subject: str, body: str, received_time: str, has_target_email: bool = True
    ):
        self.sender = sender
        self.subject = subject
        self.body = body
        self.received_time = received_time
        self.has_target_email = has_target_email  # CC/BCC check


def generate_mock_emails() -> List[MockEmail]:
    """Generate test emails"""
    return [
        MockEmail(
            sender="jeff.rowell@alphafmc.com",
            subject="[ThyNemesis] Q4 Planning Meeting",
            body="Met with project team today.\nDiscussed integration timeline.\nReady for Phase 2.",
            received_time="2026-09-02 14:30:00",
            has_target_email=True,
        ),
        MockEmail(
            sender="sarah.smith@alphafmc.com",
            subject="[ThyNemesis] Technical Requirements Review",
            body="Reviewed tech specs for implementation.\nApproved for development.\nReady to start.",
            received_time="2026-09-02 13:45:00",
            has_target_email=True,
        ),
        MockEmail(
            sender="john.doe@alphafmc.com",
            subject="ThyNemesis-Phase1 Architecture Discussion",
            body="Finalized system architecture.\nReady for development phase.\nDocs uploaded to SharePoint.",
            received_time="2026-09-02 11:20:00",
            has_target_email=True,
        ),
        MockEmail(
            sender="alice.johnson@alphafmc.com",
            subject="Meeting Notes - No Project Tag",
            body="This email has no project tag.\nShould be skipped.",
            received_time="2026-09-02 10:00:00",
            has_target_email=True,
        ),
        MockEmail(
            sender="bob.wilson@alphafmc.com",
            subject="[INVALID_PROJECT_XYZ] Some Meeting",
            body="This project doesn't exist.\nShould be skipped.",
            received_time="2026-09-02 09:30:00",
            has_target_email=True,
        ),
    ]


class ProjectFinder:
    """Finds projects by fuzzy matching project names"""

    def __init__(self):
        self.projects_root = Path("c:\\Repo\\Projects")
        self.projects = self._scan_projects()

    def _scan_projects(self) -> Dict[str, Path]:
        """Scan for all Project-* folders"""
        projects = {}
        if self.projects_root.exists():
            for folder in self.projects_root.glob("Project-*"):
                project_name = folder.name.replace("Project-", "")
                projects[project_name.upper()] = folder
        return projects

    def find_project(self, project_name: str) -> Optional[Path]:
        """Find project by fuzzy matching"""
        if not project_name:
            return None

        project_upper = project_name.upper()

        # Exact match first
        if project_upper in self.projects:
            return self.projects[project_upper]

        # Fuzzy match
        best_match = None
        best_score = 0
        for proj_name, proj_path in self.projects.items():
            score = fuzz.token_sort_ratio(project_upper, proj_name)
            if score > best_score and score >= 80:
                best_score = score
                best_match = proj_path

        return best_match

    def get_latest_phase(self, project_path: Path) -> Optional[Path]:
        """Get highest phase number folder"""
        phases = []
        for folder in project_path.glob("Phase *"):
            try:
                phase_num = int(folder.name.split()[-1])
                phases.append((phase_num, folder))
            except ValueError:
                continue

        if phases:
            phases.sort(reverse=True)
            return phases[0][1]

        return None


class EmailProcessor:
    """Processes emails and saves them to project folders"""

    MEETING_NOTES_FOLDER = "08 - Meeting Notes"
    DOCUMENTATION_FOLDER = "07 - Documentation"
    TARGET_EMAIL = "meetingNotes@Alphafmc.com"

    def __init__(self):
        self.project_finder = ProjectFinder()

    def extract_project_name(self, subject: str) -> Optional[str]:
        """Extract project name from subject line

        Supports two formats:
        - [ProjectName]
        - ProjectName-PhaseN
        """
        # Format 1: [ProjectName]
        match = re.search(r"\[([^\]]+)\]", subject)
        if match:
            return match.group(1)

        # Format 2: ProjectName-PhaseN
        match = re.search(r"^([A-Za-z0-9]+)-Phase\d+", subject)
        if match:
            return match.group(1)

        return None

    def generate_filename(self, sender: str, subject: str) -> str:
        """Generate filename: sender-subject-timestamp.md"""
        # Clean sender email to just username
        sender_name = sender.split("@")[0] if "@" in sender else sender
        sender_name = re.sub(r"[^a-zA-Z0-9_-]", "", sender_name)

        # Clean subject
        subject_clean = re.sub(r"[^\w\s-]", "", subject)
        subject_clean = re.sub(r"\s+", "-", subject_clean)
        subject_clean = subject_clean[:50]  # Limit length

        # Timestamp
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

        return f"{sender_name}-{subject_clean}-{timestamp}.md"

    def format_email_as_markdown(
        self, subject: str, sender: str, body: str, received_time: str
    ) -> str:
        """Format email as markdown"""
        return f"""# {subject}

**From:** {sender}
**Date:** {received_time}

---

{body}
"""

    def process_email(self, email: MockEmail) -> Tuple[bool, str]:
        """Process single email and save to project. Returns (success, message)"""
        try:
            # Check if email has target
            if not email.has_target_email:
                return False, f"[SKIP] {email.subject} - No {self.TARGET_EMAIL} in CC/BCC"

            # Extract project name
            project_name = self.extract_project_name(email.subject)
            if not project_name:
                return False, f"[SKIP] {email.subject} - No [ProjectName] or ProjectName-PhaseN tag"

            # Find project
            project_path = self.project_finder.find_project(project_name)
            if not project_path:
                return False, f"[SKIP] {email.subject} - Project not found: [{project_name}]"

            # Get latest phase
            phase_path = self.project_finder.get_latest_phase(project_path)
            if not phase_path:
                return False, f"[SKIP] {email.subject} - No phase folders in project"

            # Create notes folder if needed
            notes_folder = phase_path / self.MEETING_NOTES_FOLDER
            notes_folder.mkdir(parents=True, exist_ok=True)

            # Generate filename and save note
            filename = self.generate_filename(email.sender, email.subject)
            note_path = notes_folder / filename
            markdown_content = self.format_email_as_markdown(
                email.subject, email.sender, email.body, email.received_time
            )
            note_path.write_text(markdown_content, encoding="utf-8")

            rel_path = note_path.relative_to(project_path)
            return True, f"[OK] {project_name} → {rel_path}"

        except Exception as e:
            return False, f"[ERROR] {email.subject} - {e}"


def main():
    """Main sync function"""
    print("=" * 70)
    print("Nemesis Project — Email to Notes Sync (MOCK TEST)")
    print("=" * 70)
    print("")

    processor = EmailProcessor()
    mock_emails = generate_mock_emails()

    print(f"Found {len(processor.project_finder.projects)} projects:")
    for proj_name in sorted(processor.project_finder.projects.keys()):
        print(f"  - {proj_name}")
    print("")

    print(f"Processing {len(mock_emails)} mock emails...")
    print("")

    success_count = 0
    for i, email in enumerate(mock_emails, 1):
        success, message = processor.process_email(email)
        print(f"{i}. {message}")
        if success:
            success_count += 1

    print("")
    print("=" * 70)
    print(f"Results: {success_count}/{len(mock_emails)} emails processed successfully")
    print("=" * 70)
    print("")
    print("Next steps:")
    print("  1. Check files created in Project folders")
    print("  2. Verify content in 08 - Meeting Notes/")
    print("  3. Once verified, integrate real Microsoft 365 connector")
    print("")


if __name__ == "__main__":
    main()
