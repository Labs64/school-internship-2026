#!/usr/bin/env bash
#
# Linux/macOS counterpart of Insert-HtmlContent.ps1.
#
# Finds the marker pair
#
#   <!-- BEGIN:PricingTable -->
#   <!-- END:PricingTable -->
#
# in an HTML file and inserts the contents of another file between them. If
# content is already present between the markers (from a previous run), it
# is replaced with the new content, so the script can be re-run to update
# previously inserted content.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: insert-html-content.sh -t <target.html> -s <source-file> [-o <output.html>] [--no-backup]

The target file must already contain the placeholder marker pair:
  <!-- BEGIN:PricingTable -->
  <!-- END:PricingTable -->

Options:
  -t, --target <file>   HTML file to modify (required)
  -s, --source <file>   File whose contents will be inserted (required)
  -o, --output <file>   Write result to this file instead of editing
                         --target in place
      --no-backup       Do not create a .bak backup when editing in place
  -h, --help             Show this help message
EOF
}

target=""
source_file=""
output=""
backup=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target) target="$2"; shift 2 ;;
    -s|--source) source_file="$2"; shift 2 ;;
    -o|--output) output="$2"; shift 2 ;;
    --no-backup) backup=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$target" || -z "$source_file" ]]; then
  echo "Error: --target and --source are required" >&2
  usage
  exit 1
fi

if [[ ! -f "$target" ]]; then
  echo "Error: target file not found: $target" >&2
  exit 1
fi

if [[ ! -f "$source_file" ]]; then
  echo "Error: source file not found: $source_file" >&2
  exit 1
fi

begin_line="<!-- BEGIN:PricingTable -->"
end_line="<!-- END:PricingTable -->"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if ! awk -v begin_line="$begin_line" -v end_line="$end_line" -v content_file="$source_file" '
  BEGIN {
    n = 0
    while ((getline line < content_file) > 0) {
      content[n++] = line
    }
    close(content_file)
    found = 0
    in_block = 0
  }
  {
    trimmed = $0
    gsub(/^[ \t]+|[ \t]+$/, "", trimmed)

    if (!found && trimmed == begin_line) {
      print begin_line
      for (i = 0; i < n; i++) print content[i]
      found = 1
      in_block = 1
      next
    }

    if (in_block) {
      if (trimmed == end_line) {
        print end_line
        in_block = 0
      }
      next
    }

    print
  }
  END {
    exit (found ? 0 : 1)
  }
' "$target" > "$tmp_file"; then
  echo "Error: marker pair '$begin_line' .. '$end_line' not found in $target" >&2
  exit 1
fi

if [[ -n "$output" ]]; then
  cp "$tmp_file" "$output"
  echo "Wrote: $output"
else
  if [[ $backup -eq 1 ]]; then
    cp "$target" "${target}.bak"
  fi
  cp "$tmp_file" "$target"
  echo "Updated: $target"
fi
