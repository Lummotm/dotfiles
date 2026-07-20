#!/usr/bin/env python3
import ast
import os
import sys

# Should map imports with different name from the one on the  package
PACKAGE_MAPPING = {
    "PIL": "pillow",
    "cv2": "opencv-python",
    "yaml": "PyYAML",
    "sklearn": "scikit-learn",
    "bs4": "beautifulsoup4",
    "dotenv": "python-dotenv",
    "github": "PyGithub",
    "dateutil": "python-dateutil",
    "jwt": "PyJWT",
    "psycopg2": "psycopg2-binary",
}


def get_dependencies(filepath):
    if not os.path.exists(filepath):
        return

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        if "# /// script" in content:
            return

        tree = ast.parse(content)
        imports = set()

        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.add(alias.name.split(".")[0])
            elif isinstance(node, ast.ImportFrom):
                if node.module:
                    imports.add(node.module.split(".")[0])

        stdlib = getattr(sys, "stdlib_module_names", set())
        third_party = imports - stdlib - {"__future__"}

        pypi_packages = set()
        for pkg in third_party:
            pkg_name = PACKAGE_MAPPING.get(pkg, pkg).lower()
            pypi_packages.add(pkg_name)

        if pypi_packages:
            print(" ".join(pypi_packages))

    except Exception:
        pass


if __name__ == "__main__":
    if len(sys.argv) > 1:
        get_dependencies(sys.argv[1])
