import os
import shutil
import sys

config_path = sys.argv[1]
field = sys.argv[2]
prop = sys.argv[3]

temp_path = os.path.expanduser("~/config_tmp.kdl")
in_block = False

with open(config_path, "r") as original:
    with open(temp_path, "w") as new:
        for line in original:
            is_include_target = prop == "include" and field in line

            if field in line and "{" in line:
                in_block = True

            if is_include_target or (in_block and prop in line):
                clean = line.lstrip()
                indent = line[: len(line) - len(clean)]

                if clean.startswith("//"):
                    new_line = f"{indent}{clean.lstrip('/')}"
                    # Print status for it to be interpreted via a wrapper
                    print("OFF")
                else:
                    new_line = f"{indent}//{clean}"
                    # Print status for it to be interpreted via a wrapper
                    print("ON")

                new.write(new_line)

                if not is_include_target:
                    continue
                else:
                    continue

            if in_block and "}" in line:
                in_block = False

            new.write(line)

shutil.move(temp_path, config_path)
