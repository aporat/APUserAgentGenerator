#!/usr/bin/env python3
"""Compare the defaults in Sources/UAVersions.swift against vendor release feeds.

Exit status:
  0  every checked default is current, or at most one major behind
  1  a default is two or more majors behind (one or more for iOS), or the
     feeds could not be reached at all

One major behind is reported as a warning: Chromium-based browsers ship every
four weeks, so a failing job on every release would just be noise.

Only the standard library is used, so this runs on any GitHub runner.
"""

from __future__ import annotations

import json
import os
import re
import ssl
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "Sources" / "UAVersions.swift"
TIMEOUT = 30


def constants() -> dict[str, str]:
    text = SOURCE.read_text()
    return dict(re.findall(r'static let (\w+) = "([^"]+)"', text))


def fetch(url: str, *, insecure: bool = False) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": "APUserAgentGenerator-freshness"})
    context = None
    if insecure:
        # gdmf.apple.com is signed by Apple's own root, which is not in the
        # default trust store. The payload is public version metadata only.
        context = ssl._create_unverified_context()  # noqa: S323
    with urllib.request.urlopen(request, timeout=TIMEOUT, context=context) as response:
        return response.read().decode()


def chrome(platform: str) -> str:
    url = f"https://versionhistory.googleapis.com/v1/chrome/platforms/{platform}/channels/stable/versions?pageSize=1"
    return json.loads(fetch(url))["versions"][0]["version"]


def firefox() -> str:
    return json.loads(fetch("https://product-details.mozilla.org/1.0/firefox_versions.json"))["LATEST_FIREFOX_VERSION"]


def app_store(app_id: int) -> str:
    return json.loads(fetch(f"https://itunes.apple.com/lookup?id={app_id}&country=us"))["results"][0]["version"]


def edge(platform: str) -> str:
    products = json.loads(fetch("https://edgeupdates.microsoft.com/api/products"))
    stable = next(p for p in products if p["Product"] == "Stable")
    versions = [r["ProductVersion"] for r in stable["Releases"] if r["Platform"] == platform]
    return max(versions, key=version_key)


def opera_desktop() -> str:
    listing = fetch("https://get.geo.opera.com/pub/opera/desktop/")
    return max(re.findall(r'href="(\d+(?:\.\d+)+)/"', listing), key=version_key)


def opera_android() -> str:
    base = "https://get.geo.opera.com/pub/opera/android/"
    newest = max(re.findall(r'href="(\d+)/"', fetch(base)), key=int)
    builds = re.findall(r"Opera_(\d+(?:_\d+)+)_Generic", fetch(f"{base}{newest}/"))
    return max((b.replace("_", ".") for b in builds), key=version_key)


def ios() -> str:
    data = json.loads(fetch("https://gdmf.apple.com/v2/pmv", insecure=True))
    return max((a["ProductVersion"] for a in data["PublicAssetSets"]["iOS"]), key=version_key)


def version_key(version: str) -> list[int]:
    return [int(part) for part in re.findall(r"\d+", version)]


def major(version: str) -> int:
    return version_key(version)[0]


# (constant, human name, fetcher, majors behind that fail)
CHECKS = [
    ("chrome", "Chrome (desktop)", lambda: chrome("win"), 2),
    ("chromeAndroid", "Chrome (Android)", lambda: chrome("android"), 2),
    ("chromeIOS", "Chrome (iOS)", lambda: chrome("ios"), 2),
    ("firefox", "Firefox", firefox, 2),
    ("firefoxIOS", "Firefox (iOS)", lambda: app_store(989804926), 2),
    ("edge", "Edge (desktop)", lambda: edge("Windows"), 2),
    ("edgeAndroid", "Edge (Android)", lambda: edge("Android"), 2),
    ("edgeIOS", "Edge (iOS)", lambda: app_store(1288723196), 2),
    ("opera", "Opera (desktop)", opera_desktop, 2),
    ("operaAndroid", "Opera (Android)", opera_android, 2),
    ("operaIOS", "Opera (iOS)", lambda: app_store(1411869974), 2),
    ("iOS", "iOS", ios, 1),
]


def main() -> int:
    ours = constants()
    rows = []
    failures = warnings = errors = 0

    for name, label, fetcher, fail_lag in CHECKS:
        current = ours[name]
        try:
            latest = fetcher()
        except Exception as error:  # noqa: BLE001 - any feed failure is a soft warning
            errors += 1
            print(f"::warning title=Version feed unavailable::{label}: {error}")
            rows.append((label, current, "unavailable", "⚠️ feed error"))
            continue

        lag = major(latest) - major(current)
        if lag >= fail_lag:
            failures += 1
            status = f"❌ {lag} major(s) behind"
            print(f"::error file=Sources/UAVersions.swift,title=Stale default::{label}: UAVersions.{name} is {current}, latest is {latest}")
        elif lag >= 1:
            warnings += 1
            status = f"⚠️ {lag} major behind"
            print(f"::warning file=Sources/UAVersions.swift,title=Default behind::{label}: UAVersions.{name} is {current}, latest is {latest}")
        else:
            status = "✅ current"
        rows.append((label, current, latest, status))

    table = ["| Browser / OS | UAVersions | Latest | Status |", "|---|---|---|---|"]
    table += [f"| {label} | `{current}` | `{latest}` | {status} |" for label, current, latest, status in rows]
    report = "\n".join(table)
    print(report)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a") as handle:
            handle.write("## UA version freshness\n\n" + report + "\n")

    if errors == len(CHECKS):
        print("::error title=Version feeds unavailable::No vendor feed could be reached")
        return 1
    print(f"{failures} stale, {warnings} behind, {errors} unavailable")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
