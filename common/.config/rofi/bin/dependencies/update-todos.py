#!/usr/bin/env python3
import os
import re
import sys
import uuid

if len(sys.argv) > 1:
    NOTES_DIR = sys.argv[1]
else:
    NOTES_DIR = os.path.expanduser("~/Documents/Obsidian/")

EXCLUDING_KEYWORDS = {"attachments", "excalidraw", ".git", "books_vault"}
TODO_NOTE = "01_todo_inbox.md"
TODO_PRIORITY = "00_todo.md"

ID_PATTERN = r"\^([a-z0-9]{8})"
TAG_PATTERN = r"(?<!\S)#[a-zA-Z0-9/]+(?!\S)"


def generate_id():
    return f"^{uuid.uuid4().hex[0:8]}"


def is_task(line):
    s = line.lstrip()
    return s.startswith("- [ ]") or s.startswith("- [x]") or s.startswith("- [X]")


def sync_back_tasks():
    updates_by_note = {}
    todo_files = [
        os.path.join(NOTES_DIR, TODO_NOTE),
        os.path.join(NOTES_DIR, TODO_PRIORITY),
    ]

    for todo_path in todo_files:
        if not os.path.exists(todo_path):
            continue

        todo_mtime = os.path.getmtime(todo_path)

        with open(todo_path, "r", encoding="utf-8") as f:
            for line in f:
                if not is_task(line):
                    continue

                status = line.lstrip()[3]

                id_match = re.search(ID_PATTERN, line)
                if not id_match:
                    continue
                task_id = id_match.group(0)

                link_start = line.find("[[")
                link_end = line.find("]]")
                if link_start == -1 or link_end == -1:
                    continue
                note_name = line[link_start + 2 : link_end]

                text_start_idx = line.find("]") + 2
                text_end_idx = line.find(task_id)
                text = line[text_start_idx:text_end_idx].strip()

                if note_name not in updates_by_note:
                    updates_by_note[note_name] = {}

                if task_id not in updates_by_note[note_name]:
                    updates_by_note[note_name][task_id] = []

                updates_by_note[note_name][task_id].append(
                    {
                        "status": status,
                        "text": text,
                        "todo_mtime": todo_mtime,
                    }
                )

    if not updates_by_note:
        return

    note_paths = {}
    for root, dirs, files in os.walk(NOTES_DIR):
        dirs[:] = [
            d
            for d in dirs
            if not d.startswith(".")
            and not any(kw in d.lower() for kw in EXCLUDING_KEYWORDS)
        ]
        for file in files:
            if file.endswith(".md"):
                note_name = file[:-3]
                if note_name in updates_by_note:
                    note_paths[note_name] = os.path.join(root, file)

    for note_name, tasks_to_update in updates_by_note.items():
        if note_name not in note_paths:
            continue

        file_path = note_paths[note_name]
        note_mtime = os.path.getmtime(file_path)
        changed = False
        updated_lines = []

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            for line in lines:
                if is_task(line):
                    id_match = re.search(ID_PATTERN, line)
                    if id_match:
                        task_id = id_match.group(0)
                        if task_id in tasks_to_update:
                            current_status = line.lstrip()[3]
                            text_start_idx = line.find("]") + 2
                            text_end_idx = line.find(task_id)
                            current_text = line[text_start_idx:text_end_idx].strip()

                            # Normalizamos espacios para que no falle por chorradas de formato
                            current_text_clean = " ".join(current_text.split())

                            for data in tasks_to_update[task_id]:
                                data_text_clean = " ".join(data["text"].split())

                                if data["todo_mtime"] >= note_mtime:
                                    if (
                                        data_text_clean != current_text_clean
                                        or data["status"] != current_status
                                    ):
                                        print(f"🔄 ACTUALIZANDO NOTA: {note_name}")
                                        print(
                                            f"  - Antes: {current_text_clean} [{current_status}]"
                                        )
                                        print(
                                            f"  - Ahora: {data_text_clean} [{data['status']}]"
                                        )

                                        prefix_spaces = line[
                                            : len(line) - len(line.lstrip())
                                        ]
                                        new_line = f"{prefix_spaces}- [{data['status']}] {data['text']} {task_id}\n"

                                        if line != new_line:
                                            line = new_line
                                            changed = True
                                        break
                updated_lines.append(line)

            if changed:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.writelines(updated_lines)
        except Exception as e:
            print(f"Error en {file_path}: {e}")


def process_line(line):
    if not is_task(line):
        return line

    clean_line = line.rstrip()

    id_match = re.search(ID_PATTERN, clean_line)
    task_id = id_match.group(0) if id_match else ""

    if not task_id and clean_line.lstrip().startswith("- [ ]"):
        task_id = generate_id()

    tags = re.findall(TAG_PATTERN, clean_line)

    raw_text = clean_line
    if id_match:
        raw_text = raw_text.replace(task_id, "")
    for tag in set(tags):
        raw_text = re.sub(rf"(?<!\S){tag}(?!\S)", "", raw_text)

    stripped = raw_text.lstrip()
    prefix_spaces = raw_text[: len(raw_text) - len(stripped)]
    status_box = stripped[:5]
    text_content = stripped[5:].strip()

    text_content = " ".join(text_content.split())

    new_line = prefix_spaces + status_box
    if text_content:
        new_line += f" {text_content}"
    if tags:
        new_line += f" {' '.join(tags)}"
    if task_id:
        new_line += f" {task_id}"

    return new_line + "\n"


sync_back_tasks()

inbox_tasks = []
priority_tasks = {}

for root, dirs, files in os.walk(NOTES_DIR):
    dirs[:] = [
        d
        for d in dirs
        if not d.startswith(".")
        and not any(kw in d.lower() for kw in EXCLUDING_KEYWORDS)
    ]

    for file in files:
        if not file.endswith(".md") or file in {TODO_NOTE, TODO_PRIORITY}:
            continue

        file_path = os.path.join(root, file)
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()
        except Exception:
            continue

        file_changed = False
        new_lines = []

        for line in lines:
            processed_line = process_line(line)

            if line != processed_line:
                file_changed = True
            new_lines.append(processed_line)

            if is_task(processed_line) and processed_line.lstrip().startswith("- [ ]"):
                tags = re.findall(TAG_PATTERN, processed_line)
                nombre_nota = file.replace(".md", "")

                clean_task = processed_line.rstrip()
                task_with_link = f"{clean_task} [[{nombre_nota}]]"

                if tags:
                    # Usamos exclusivamente el primer tag para crear la sección
                    primer_tag = tags[0]

                    if primer_tag not in priority_tasks:
                        priority_tasks[primer_tag] = []

                    # La variable task_with_link sigue teniendo todos los tags extra pegados al final
                    if task_with_link not in priority_tasks[primer_tag]:
                        priority_tasks[primer_tag].append(task_with_link)
                else:
                    inbox_tasks.append(task_with_link)

        if file_changed:
            with open(file_path, "w", encoding="utf-8") as f:
                f.writelines(new_lines)


def sort_key(tag):
    if "#urgent" in tag:
        return 0, tag
    if "#math" in tag:
        return 1, tag
    return 999, tag


inbox_path = os.path.join(NOTES_DIR, TODO_NOTE)
with open(inbox_path, "w", encoding="utf-8") as f:
    f.write("---\nid: 01_todo_inbox\ntags: []\naliases: []\n---\n\n# 📥 Inbox\n\n")
    if not inbox_tasks:
        f.write("No hay tareas pendientes.\n")
    else:
        for t in inbox_tasks:
            f.write(f"{t}\n")

priority_path = os.path.join(NOTES_DIR, TODO_PRIORITY)
with open(priority_path, "w", encoding="utf-8") as f:
    f.write("---\nid: 00_todo\ntags: []\naliases: []\n---\n\n# 🏷️ Tareas por Tag\n\n")
    if not priority_tasks:
        f.write("No hay tareas tageadas.\n")
    else:
        sorted_tags = sorted(priority_tasks.keys(), key=sort_key)
        for tag in sorted_tags:
            tag_str = tag.replace("#", "")
            f.write(f"## {tag_str}\n")
            for t in priority_tasks[tag]:
                f.write(f"{t}\n")
            f.write("\n")
