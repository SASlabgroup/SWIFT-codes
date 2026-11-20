"""Check netCDF files against CF-1.8 with cfchecks and the IOOS compliance-checker

    python Python/check_cf.py file1.nc dir/*.nc

For each file, prints the errors and warnings from both checkers, then a
one-line summary per file. cfchecks (cfchecker) is the strict CF checker;
compliance-checker (--test cf:1.8) also reports recommendations.

Setup (pyenv-virtualenv 'swift-codes'):
    brew install udunits
    pyenv virtualenv 3.11.10 swift-codes
    UDUNITS2_INCDIR=/opt/homebrew/include UDUNITS2_LIBDIR=/opt/homebrew/lib \
        UDUNITS2_XML_PATH=/opt/homebrew/share/udunits/udunits2.xml \
        ~/.pyenv/versions/swift-codes/bin/pip install cfchecker compliance-checker
    ~/.pyenv/versions/swift-codes/bin/python Python/check_cf.py file.nc

cfchecks finds the udunits2 library through DYLD_FALLBACK_LIBRARY_PATH,
which is set to Homebrew's lib for it here.

Changelog:
2026-11-19 M. LeClair w/ claude: created, runs cfchecks and compliance-checker
"""
import json
import os
import subprocess
import sys
from pathlib import Path

CF_VERSION = '1.8'
BIN_DIR = Path(sys.executable).parent  # checkers installed in this venv
HOMEBREW_LIB = '/opt/homebrew/lib'     # udunits2 for cfchecks (macOS)


def run_cfchecks(path):
    """cfchecks ERROR/WARN lines, prefixed with the variable they are about"""
    env = dict(os.environ)
    env['DYLD_FALLBACK_LIBRARY_PATH'] = HOMEBREW_LIB
    result = subprocess.run([BIN_DIR / 'cfchecks', '-v', CF_VERSION, path],
                            capture_output=True, text=True, env=env)
    if 'ERRORS detected' not in result.stdout:
        raise RuntimeError(f'cfchecks failed on {path}:\n{result.stderr}')
    errors, warnings = [], []
    variable = '(global)'
    for line in result.stdout.splitlines():
        if line.startswith('Checking variable:'):
            variable = line.split(':', 1)[1].strip()
        elif line.startswith('ERROR:'):
            errors.append(f'{variable}: {line}')
        elif line.startswith('WARN:'):
            warnings.append(f'{variable}: {line}')
    return errors, warnings


def run_compliance_checker(path):
    """compliance-checker messages: high priority as errors, medium as warnings"""
    result = subprocess.run([BIN_DIR / 'compliance-checker', '--test', f'cf:{CF_VERSION}',
                             '-f', 'json', '-o', '-', path],
                            capture_output=True, text=True)
    report = next(iter(json.loads(result.stdout).values()))

    def messages(priority):
        return [f'{check["name"]}: {msg}' for check in report[priority] for msg in check['msgs']]

    return messages('high_priorities'), messages('medium_priorities')


def print_section(title, lines):
    print(f'  {title} ({len(lines)})')
    for line in lines:
        print(f'    {line}')


def main(paths):
    summaries = []
    for path in paths:
        print(f'=== {path}')
        cf_errors, cf_warnings = run_cfchecks(path)
        cc_errors, cc_warnings = run_compliance_checker(path)
        print('cfchecks')
        print_section('ERRORS', cf_errors)
        print_section('WARNINGS', cf_warnings)
        print('compliance-checker')
        print_section('high priority', cc_errors)
        print_section('medium priority', cc_warnings)
        summaries.append(f'{Path(path).name}: cfchecks {len(cf_errors)} errors, {len(cf_warnings)} warnings; '
                         f'compliance-checker {len(cc_errors)} high, {len(cc_warnings)} medium')
    print('\n=== Summary')
    print('\n'.join(summaries))


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    main(sys.argv[1:])
