import json
import sys
import os

def map_severity(level):
    severity_map = {
        "CRITICAL": "CRITICAL",
        "HIGH": "MAJOR",
        "MEDIUM": "MINOR",
        "LOW": "INFO"
    }
    return severity_map.get(level.upper(), "INFO")

def parse_sarif(sarif_file):
    with open(sarif_file, 'r') as f:
        sarif = json.load(f)

    results = []
    runs = sarif.get("runs", [])
    for run in runs:
        tool_name = run.get("tool", {}).get("driver", {}).get("name", "trivy")
        rules = run.get("tool", {}).get("driver", {}).get("rules", [])
        rule_map = {rule.get("id"): rule for rule in rules}

        for result in run.get("results", []):
            rule_id = result.get("ruleId", "UNKNOWN")
            message = result.get("message", {}).get("text", "No message provided")
            locations = result.get("locations", [])

            for loc in locations:
                file_path = loc.get("physicalLocation", {}).get("artifactLocation", {}).get("uri", "UNKNOWN")
                region = loc.get("physicalLocation", {}).get("region", {})
                line = region.get("startLine", 1)

                rule = rule_map.get(rule_id, {})
                severity = rule.get("properties", {}).get("security-severity", "LOW")

                results.append({
                    "engineId": tool_name,
                    "ruleId": rule_id,
                    "severity": map_severity(severity),
                    "type": "VULNERABILITY",
                    "primaryLocation": {
                        "message": message,
                        "filePath": file_path,
                        "textRange": {
                            "startLine": line
                        }
                    }
                })

    return results

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python sarif_to_sonar.py <input.sarif> <output.json>")
        sys.exit(1)

    input_sarif = sys.argv[1]
    output_json = sys.argv[2]

    if not os.path.exists(input_sarif):
        print(f"Error: SARIF file '{input_sarif}' not found.")
        sys.exit(1)

    generic_issues = parse_sarif(input_sarif)

    output_data = {
        "issues": generic_issues
    }

    with open(output_json, 'w') as f:
        json.dump(output_data, f, indent=2)

    print(f"✅ Successfully converted SARIF to SonarQube Generic Issue format: {output_json}")
