#!/usr/bin/env python3

import argparse
import hashlib
import json
import sys
from pathlib import Path
from datetime import datetime

BASELINE_FILE = Path("baseline.json")
CONFIG_FILE = Path("files.conf")


def calculate_hash(file_path):
    sha256 = hashlib.sha256()

    with open(file_path, "rb") as file:
        for block in iter(lambda: file.read(4096), b""):
            sha256.update(block)

    return sha256.hexdigest()


def init_baseline():
    print("Création de la baseline...")

    baseline = {}

    with open(CONFIG_FILE, "r", encoding="utf-8") as config:
        files = [line.strip() for line in config if line.strip()]

    for file_name in files:
        file_path = Path(file_name)

        if file_path.is_file():
            file_hash = calculate_hash(file_path)

            baseline[file_name] = {
                    "sha256": file_hash
            }

        else:
            print(f"WARNING - Fichier introuvable : {file_path}")

    with open(BASELINE_FILE, "w", encoding="utf-8") as file:
        json.dump(baseline, file, indent=4)

    print(f"Baseline créée dans {BASELINE_FILE}")


def check_integrity():
    print("Vérification de l'intégrité...")
    
    status = 0
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    report = {
            "timestamp": timestamp,
            "status": "OK",
            "checked_files": 0,
            "ok": 0,
            "modified": 0,
            "missing": 0 
            }

    if not BASELINE_FILE.is_file():
        print(f"{timestamp} - UNKNOWN - Baseline introuvable")
        return 3

    with open(BASELINE_FILE, "r", encoding="utf-8") as file:
       baseline = json.load(file)

    for file_name, data in baseline.items():
        expected_hash = data["sha256"]
        file_path = Path(file_name)

        report["checked_files"] += 1 

        if not file_path.is_file():
            print(f"{timestamp} - CRITICAL - Fichier absent : {file_path}")
            report["missing"] += 1
            status = 2
            continue

        current_hash = calculate_hash(file_path)

        if current_hash == expected_hash:
            print(f"{timestamp} - OK - {file_path} inchangé")
            report["ok"] += 1
        else:
            print(f"{timestamp} - CRITICAL - {file_path} modifié")
            report["modified"] += 1
            status = 2

    if status == 2:
        report["status"] = "CRITICAL"

    report_file = Path("fim-report.json")

    with open(report_file, "w", encoding="utf-8") as file:
        json.dump(report, file, indent=4)

    print(f"Rapport généré : {report_file}")

    return status

def main():
    parser = argparse.ArgumentParser(
        description="File Integrity Monitoring simple basé sur SHA-256"
    )

    parser.add_argument(
        "--init",
        action="store_true",
        help="Créer la baseline"
    )

    parser.add_argument(
        "--check",
        action="store_true",
        help="Vérifier l'intégrité des fichiers"
    )

    args = parser.parse_args()

    if args.init:
        init_baseline()

    elif args.check:
        sys.exit(check_integrity())

    else:
        parser.print_help()
        sys.exit(3)


if __name__ == "__main__":
    main()
