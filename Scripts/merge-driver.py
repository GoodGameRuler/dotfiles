#!/usr/bin/env python

import sys, os
import filecmp

GIT_DRIVER_ARGS = 5

def main(base_file: str, curr_branch_file: str, new_branch_file, conflict_marker_size, pathname: str) -> None:

    print(base_file, curr_branch_file, new_branch_file, conflict_marker_size, pathname)

    MERGE_TEMPLATE_FILE = os.path.join(pathname, "template.md") if \
        os.path.exists(os.path.join(pathname, "template.md")) else os.getenv("MERGE_TEMPLATE_FILE")

    if not MERGE_TEMPLATE_FILE:
        sys.exit(1)

    if filecmp.cmp(curr_branch_file, MERGE_TEMPLATE_FILE, False):
        with open(new_branch_file, "rb") as cbf:
            with open(base_file, "wb") as bf:
                bf.write(cbf.read());

        return

    sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) == GIT_DRIVER_ARGS:
        print(f"Should have {GIT_DRIVER_ARGS} number of arguments; had {len(sys.argv)}", file=sys.stderr)

    main(*sys.argv)
    sys.exit(0)
