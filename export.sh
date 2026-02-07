#!/bin/bash
# conda_export_dated.sh
# Usage: ./conda_export_dated.sh [prefix]

set -e

PREFIX="${1:-$(basename $CONDA_PREFIX)}"
DATE=$(date +%-m-%-d-%Y)
DIR="conda_exports"
mkdir -p "$DIR"

echo "📦 Exporting ${PREFIX} environment..."

# Conda exports
conda env export > "${DIR}/${PREFIX}-${DATE}.yml"
conda env export --from-history > "${DIR}/${PREFIX}-${DATE}-minimal.yml"

# Python package exports
pip freeze > "${DIR}/${PREFIX}-${DATE}-pip-freeze.txt"

# UV export (if available)
if command -v uv &> /dev/null; then
    uv pip freeze > "${DIR}/${PREFIX}-${DATE}-uv.txt" 2>/dev/null || true
    if [ -f "pyproject.toml" ]; then
        uv lock --output-file "${DIR}/${PREFIX}-${DATE}.lock" 2>/dev/null || true
    fi
    echo "✅ UV exports included"
fi

# List created files
echo ""
echo "✅ Exported to ${DIR}:"
ls -lh "${DIR}/${PREFIX}-${DATE}"*

echo ""
echo "Recreate with:"
echo "  conda env create -f ${DIR}/${PREFIX}-${DATE}.yml"
[ -f "${DIR}/${PREFIX}-${DATE}-uv.txt" ] && echo "  uv pip sync ${DIR}/${PREFIX}-${DATE}-uv.txt"
