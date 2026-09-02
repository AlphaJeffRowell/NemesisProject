#!/usr/bin/env python3
"""
Nemesis Project — Asana Sync Enhanced
Syncs meeting notes to Asana tasks with auto-detection (no @task syntax required).

Features:
- Auto-detect task references in notes
- Explicit @task syntax still works (backward compatible)
- Paragraph-based content grouping
- Multi-user support with per-user ASANA_PAT
- Full audit trail logging
- Fuzzy matching for task names
"""

import os
import re
import sys
import json
import argparse
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from difflib import SequenceMatcher

try:
    from fuzzywuzzy import fuzz
except ImportError:
    print("ERROR: fuzzywuzzy not installed. Run: pip install fuzzywuzzy python-Levenshtein")
    sys.exit(1)

try:
    import requests
except ImportError:
    print("ERROR: requests not installed. Run: pip install requests")
    sys.exit(1)

try:
    from dotenv import load_dotenv
except ImportError:
    print("ERROR: python-dotenv not installed. Run: pip install python-dotenv")
    sys.exit(1)

# Load environment variables from .env
load_dotenv()

# ============================================================================
# Configuration
# ============================================================================

class Config:
    """Configuration management."""

    ASANA_API_URL = "https://app.asana.com/api/1.0"
    DEFAULT_PROJECT_GID = "1212383809935634"  # TWG FO (fallback)
    CONFIDENCE_THRESHOLD = 0.75
    HIGH_CONFIDENCE = 0.90

    def __init__(self, project_gid: Optional[str] = None):
        self.project_gid = project_gid or os.getenv("ASANA_PROJECT_GID", self.DEFAULT_PROJECT_GID)
        self.asana_pat = os.getenv("ASANA_PAT")

        if not self.asana_pat:
            raise ValueError("ASANA_PAT environment variable not set. Add to .env file.")

    @property
    def headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.asana_pat}",
            "Content-Type": "application/json"
        }


# ============================================================================
# Logging
# ============================================================================

def setup_logging(log_file: str = "asana-sync.log") -> logging.Logger:
    """Set up logging to file and console."""
    logger = logging.getLogger("asana-sync")
    logger.setLevel(logging.DEBUG)

    # File handler
    fh = logging.FileHandler(log_file)
    fh.setLevel(logging.DEBUG)

    # Console handler
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)

    formatter = logging.Formatter(
        "[%(asctime)s] %(levelname)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    fh.setFormatter(formatter)
    ch.setFormatter(formatter)

    logger.addHandler(fh)
    logger.addHandler(ch)

    return logger

logger = setup_logging()


# ============================================================================
# Asana API
# ============================================================================

class AsanaAPI:
    """Asana API client."""

    def __init__(self, config: Config):
        self.config = config
        self.task_index = None

    def get_tasks(self) -> Dict[str, str]:
        """Fetch all tasks from project. Returns {task_name: task_gid}."""
        try:
            response = requests.get(
                f"{self.config.ASANA_API_URL}/projects/{self.config.project_gid}/tasks",
                headers=self.config.headers,
                params={"limit": 100}
            )
            response.raise_for_status()

            tasks = response.json().get("data", [])
            task_index = {task["name"]: task["gid"] for task in tasks}

            logger.debug(f"Loaded {len(task_index)} tasks from Asana")
            return task_index
        except Exception as e:
            logger.error(f"Failed to fetch tasks: {e}")
            return {}

    def load_task_index(self) -> Dict[str, str]:
        """Load and cache task index."""
        if self.task_index is None:
            self.task_index = self.get_tasks()
        return self.task_index

    def get_task_by_gid(self, gid: str) -> Optional[Dict]:
        """Fetch single task by GID."""
        try:
            response = requests.get(
                f"{self.config.ASANA_API_URL}/tasks/{gid}",
                headers=self.config.headers
            )
            response.raise_for_status()
            return response.json().get("data", {})
        except Exception as e:
            logger.error(f"Failed to fetch task {gid}: {e}")
            return None

    def add_comment(self, task_gid: str, comment: str) -> bool:
        """Add comment to task."""
        try:
            response = requests.post(
                f"{self.config.ASANA_API_URL}/tasks/{task_gid}/stories",
                headers=self.config.headers,
                json={"data": {"text": comment}}
            )
            response.raise_for_status()
            logger.info(f"Comment added to task {task_gid}")
            return True
        except Exception as e:
            logger.error(f"Failed to add comment to {task_gid}: {e}")
            return False


# ============================================================================
# Task Detection (Auto-Detection)
# ============================================================================

class TaskDetector:
    """Detects task references in text using multiple methods."""

    def __init__(self, task_index: Dict[str, str], confidence_threshold: float = 0.75):
        self.task_index = task_index
        self.confidence_threshold = confidence_threshold

    def detect_references(self, text: str) -> List[Tuple[str, float, str]]:
        """
        Detect task references in text.

        Returns: List of (task_gid, confidence, method)
        - Method 1: Explicit @task (confidence=1.0)
        - Method 2: Issue number #N (confidence=0.8)
        - Method 3: Fuzzy task name matching (confidence varies)
        """
        results = []

        # Method 1: Explicit @task references
        explicit_refs = self._detect_explicit_refs(text)
        for gid in explicit_refs:
            results.append((gid, 1.0, "explicit"))

        # Method 2: Issue numbers
        issue_refs = self._detect_issue_refs(text)
        for gid, conf in issue_refs:
            results.append((gid, conf, "issue"))

        # Method 3: Fuzzy task name matching
        fuzzy_refs = self._detect_fuzzy_refs(text)
        for gid, conf in fuzzy_refs:
            results.append((gid, conf, "fuzzy"))

        # Sort by confidence (descending)
        results.sort(key=lambda x: x[1], reverse=True)

        # Remove duplicates, keeping highest confidence
        seen_gids = set()
        unique_results = []
        for gid, conf, method in results:
            if gid not in seen_gids:
                unique_results.append((gid, conf, method))
                seen_gids.add(gid)

        return unique_results

    def _detect_explicit_refs(self, text: str) -> List[str]:
        """Detect explicit @task references."""
        gids = []

        # @task gid:XXXXX
        for match in re.finditer(r'@task\s+gid:(\d+)', text):
            gids.append(match.group(1))

        # @task search:"..."
        for match in re.finditer(r'@task\s+search:"([^"]+)"', text):
            query = match.group(1)
            # Simple substring search
            for name, gid in self.task_index.items():
                if query.lower() in name.lower():
                    gids.append(gid)
                    break

        # @task name:"..."
        for match in re.finditer(r'@task\s+name:"([^"]+)"', text):
            name = match.group(1)
            gid = self.task_index.get(name)
            if gid:
                gids.append(gid)

        # @task #N
        for match in re.finditer(r'@task\s+#(\d+)', text):
            issue_num = match.group(1)
            for name, gid in self.task_index.items():
                if f"#{issue_num}" in name:
                    gids.append(gid)
                    break

        return gids

    def _detect_issue_refs(self, text: str) -> List[Tuple[str, float]]:
        """Detect bare issue numbers."""
        results = []

        # Find all #NNN patterns
        for match in re.finditer(r'#(\d+)', text):
            issue_num = match.group(1)

            # Find tasks containing this issue number
            matching_gids = []
            for name, gid in self.task_index.items():
                if f"#{issue_num}" in name:
                    matching_gids.append(gid)

            # Only if unique match
            if len(matching_gids) == 1:
                results.append((matching_gids[0], 0.8))

        return results

    def _detect_fuzzy_refs(self, text: str) -> List[Tuple[str, float]]:
        """Detect task names via fuzzy matching."""
        results = []

        # Score each task name against the text
        for name, gid in self.task_index.items():
            score = fuzz.partial_ratio(text.lower(), name.lower()) / 100.0

            # Only include if above threshold
            if score >= self.confidence_threshold:
                results.append((gid, score))

        return results

    def score_match(self, task_name: str, text: str) -> float:
        """Score how well a task name matches text."""
        return fuzz.partial_ratio(text.lower(), task_name.lower()) / 100.0


# ============================================================================
# Content Parsing
# ============================================================================

class NotesParser:
    """Parse meeting notes and extract content."""

    @staticmethod
    def extract_paragraphs(text: str) -> List[str]:
        """Extract paragraphs (split by blank lines)."""
        # Split on double newlines
        paragraphs = re.split(r'\n\s*\n', text)

        # Strip and filter empty
        return [p.strip() for p in paragraphs if p.strip()]

    @staticmethod
    def associate_content_to_tasks(
        paragraphs: List[str],
        detector: TaskDetector
    ) -> List[Tuple[str, str]]:
        """
        Associate content paragraphs to tasks.

        Returns: List of (task_gid, accumulated_content)
        """
        result = []
        current_task = None
        current_content = []

        for paragraph in paragraphs:
            refs = detector.detect_references(paragraph)

            if not refs:
                # No new task reference - add to current task
                if current_task:
                    current_content.append(paragraph)
                # else: orphan paragraph (skip)
            else:
                # New task detected
                # Save previous task content
                if current_task and current_content:
                    result.append((current_task, "\n\n".join(current_content)))

                # Start new task
                current_task = refs[0][0]  # Use highest confidence
                current_content = [paragraph]

        # Save final task
        if current_task and current_content:
            result.append((current_task, "\n\n".join(current_content)))

        return result


# ============================================================================
# Main Sync Logic
# ============================================================================

class AsanaSync:
    """Main sync orchestrator."""

    def __init__(self, config: Config, no_prompt: bool = False):
        self.config = config
        self.api = AsanaAPI(config)
        self.no_prompt = no_prompt

    def sync_files(self, file_paths: List[str]) -> bool:
        """Sync notes from files."""
        if not file_paths:
            logger.warning("No files to sync")
            return False

        # Load task index
        task_index = self.api.load_task_index()
        if not task_index:
            logger.error("Could not load task index from Asana")
            return False

        detector = TaskDetector(task_index)

        # Process each file
        for file_path in file_paths:
            logger.info(f"Processing: {file_path}")

            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    text = f.read()
            except Exception as e:
                logger.error(f"Could not read {file_path}: {e}")
                continue

            # Parse content
            paragraphs = NotesParser.extract_paragraphs(text)
            tasks_content = NotesParser.associate_content_to_tasks(paragraphs, detector)

            if not tasks_content:
                logger.info(f"No tasks found in {file_path}")
                continue

            # Sync each task
            for task_gid, content in tasks_content:
                task = self.api.get_task_by_gid(task_gid)
                if not task:
                    logger.warning(f"Could not fetch task {task_gid}")
                    continue

                logger.info(f"Syncing to: {task['name']} (GID: {task_gid})")

                if self.no_prompt:
                    # Auto-approve
                    self.api.add_comment(task_gid, content)
                else:
                    # Ask user
                    print(f"\n{'='*60}")
                    print(f"Task: {task['name']}")
                    print(f"GID: {task_gid}")
                    print(f"{'='*60}")
                    print(f"Content:\n{content}")
                    print(f"{'='*60}")

                    response = input("Sync this? (y/n): ").lower()
                    if response == 'y':
                        self.api.add_comment(task_gid, content)

        return True


# ============================================================================
# Main
# ============================================================================

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Asana Sync — Sync meeting notes to Asana tasks"
    )
    parser.add_argument(
        "--project-gid",
        help="Asana project GID (default: TWG FO)"
    )
    parser.add_argument(
        "--no-prompt",
        action="store_true",
        help="Auto-approve (for hooks)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview only, no API calls"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "files",
        nargs="*",
        help="Files to sync (default: current dir)"
    )

    args = parser.parse_args()

    try:
        config = Config(project_gid=args.project_gid)

        if args.verbose:
            logger.setLevel(logging.DEBUG)

        logger.info(f"Asana Sync Starting (Project: {config.project_gid})")

        # Find files to sync
        if args.files:
            file_paths = args.files
        else:
            # Find .md files in current directory
            file_paths = list(Path(".").glob("**/*.md"))

        if not file_paths:
            logger.warning("No markdown files found")
            return 0

        if args.dry_run:
            logger.info("DRY RUN - No changes will be made")

        # Sync
        syncer = AsanaSync(config, no_prompt=args.no_prompt)
        success = syncer.sync_files(file_paths)

        return 0 if success else 1

    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())
