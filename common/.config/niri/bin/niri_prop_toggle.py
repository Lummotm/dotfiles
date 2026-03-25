import sys
import os
import shutil

dir = sys.argv[1]
field = sys.argv[2]
prop = sys.argv[3]
inBlock = False
test_dir = "~/config_tmp.kdl"  # Esto siempre esta en el equipo cualquier subdirectorio podría no estar
test_dir = os.path.expanduser(test_dir)


print(f"Trabajando en {dir}")

with open(dir, "r") as original:
    with open(test_dir, "w") as new:
        for line in original:

            if field in line:
                if "{" in line:
                    inBlock = True

            if inBlock and prop in line:
                clean = line.lstrip()

                # Creo bloque de intendado para mantener coherencia
                spaces = len(line) - len(clean)
                indent = line[:spaces]

                if clean.startswith("//"):
                    line = clean.lstrip("/")
                    line = f"{indent}{line}"
                    _ = new.write(line)

                else:
                    line = f"{indent}//{clean}"
                    _ = new.write(line)

                # Cuando ha acabado la línea pasamos el bucle
                continue

            if inBlock and "}" in line:
                inBlock = False

            _ = new.write(line)

_ = shutil.move(test_dir, dir)
