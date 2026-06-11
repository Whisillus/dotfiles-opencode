---
name: process-pdf
description: Use when working with PDF files: reading, extracting text or tables, OCR, merging, splitting, rotating, watermarking, filling forms, encrypting, decrypting, creating PDFs, or reviewing PDF workflows for security.
license: Original local opencode skill; do not copy proprietary upstream materials.
---

# PDF

Use this skill whenever the user asks to inspect, extract, transform, create, fill, OCR, or secure PDF files.

## Safety Rules

- Treat every PDF as untrusted input. Do not execute embedded JavaScript, launch actions, attachments, links, or external handlers from a PDF.
- Do not upload PDFs to external services, cloud OCR, or online converters unless the user explicitly approves that exact file and destination.
- Do not overwrite the input PDF unless the user explicitly asks. Prefer a new output filename and keep the original intact.
- Do not install new PDF tools or Python/Node packages unless the user approves dependency changes. Prefer tools already present in the repo or system.
- Avoid leaking passwords in shell history or logs. Prefer environment variables, prompt-based tools, or short-lived local files with restrictive permissions when handling protected PDFs.
- Quote paths, pass subprocess arguments as arrays in scripts, and avoid `shell=True` unless shell semantics are required.
- Use a temporary working directory for generated page images, OCR text, crops, and intermediate PDFs; remove sensitive intermediates when the task is complete.
- If privacy matters, check metadata and embedded files before returning or sharing a PDF.

## Tool Selection

- **Inspect and validate**: `qpdf --check`, `pdfinfo`, `pypdf.PdfReader`.
- **Plain text extraction**: `pdftotext` for speed, `pdfplumber` for layout-sensitive extraction, `pypdf` for simple cases.
- **Tables and coordinates**: `pdfplumber` first; consider Camelot/Tabula only if already installed or explicitly approved.
- **Merge, split, rotate, encrypt, decrypt, linearize**: `qpdf` for command-line workflows; `pypdf` for Python workflows.
- **Render pages or thumbnails**: `pdftoppm`, `pypdfium2`, or `pdf2image`.
- **OCR scanned pages**: render locally, then use `tesseract` or `pytesseract` if available.
- **Extract embedded images**: `pdfimages` preserves original image data better than page rendering.
- **Create new PDFs**: `reportlab` in Python or `pdf-lib` in JavaScript, matching the project stack.

## Workflow

1. Confirm the user's goal, input path, output path, page range, password requirements, and whether in-place changes are acceptable.
2. Inspect available project tooling before choosing commands or adding scripts.
3. For transformations, write to a new output file and validate it before considering the task complete.
4. For layout-sensitive tasks, render one or more pages to images and visually verify placement or extraction quality when feasible.
5. For forms, first determine whether the PDF has AcroForm/XFA fields. Use native fields when available; otherwise overlay annotations/text on rendered-coordinate positions.

## Common Commands

```bash
# Validate structure
qpdf --check input.pdf

# Extract text
pdftotext -layout input.pdf output.txt

# Merge PDFs
qpdf --empty --pages part1.pdf part2.pdf -- merged.pdf

# Extract a page range
qpdf input.pdf --pages input.pdf 1-5 -- first-five-pages.pdf

# Rotate page 1 clockwise
qpdf input.pdf rotated.pdf --rotate=+90:1

# Render pages to PNG at 200 DPI
pdftoppm -png -r 200 input.pdf pages/page

# Extract embedded images
pdfimages -all input.pdf images/image
```

## Python Patterns

Use `pathlib.Path`, explicit output paths, and project-local environments. Keep examples small and adapt to the repository's toolchain.

### Page Count and Metadata

```python
from pathlib import Path
from pypdf import PdfReader

pdf_path = Path("input.pdf")
reader = PdfReader(pdf_path)
print({"pages": len(reader.pages), "metadata": dict(reader.metadata or {})})
```

### Text and Tables

```python
import pdfplumber

with pdfplumber.open("input.pdf") as pdf:
    for page_number, page in enumerate(pdf.pages, start=1):
        text = page.extract_text() or ""
        tables = page.extract_tables()
        print(page_number, len(text), len(tables))
```

### Merge Without Overwriting Inputs

```python
from pathlib import Path
from pypdf import PdfReader, PdfWriter

inputs = [Path("part1.pdf"), Path("part2.pdf")]
output = Path("merged.pdf")

writer = PdfWriter()
for input_path in inputs:
    reader = PdfReader(input_path)
    for page in reader.pages:
        writer.add_page(page)

with output.open("wb") as file:
    writer.write(file)
```

### Fill AcroForm Fields

```python
from pathlib import Path
from pypdf import PdfReader, PdfWriter

input_path = Path("form.pdf")
output_path = Path("filled-form.pdf")
field_values = {"full_name": "Ada Lovelace"}

reader = PdfReader(input_path)
writer = PdfWriter()
writer.append(reader)
writer.set_need_appearances_writer()

for page in writer.pages:
    writer.update_page_form_field_values(page, field_values)

with output_path.open("wb") as file:
    writer.write(file)
```

## Form Filling Guidance

- Check for fillable fields before adding overlays. In Python, inspect `PdfReader(path).get_fields()`.
- For checkboxes and radio buttons, use the exact export values from the field dictionary rather than guessing `true` or `yes`.
- For non-fillable forms, render pages to images, identify field coordinates, overlay text/checkmarks with `reportlab`, then merge the overlay back onto the original page.
- Keep one coordinate system per `fields.json` or script. PDF coordinates usually start at the bottom-left; image coordinates usually start at the top-left.
- Validate bounding boxes for overlap and sufficient font size before producing the final PDF.
- Verify the filled result by rendering the output PDF to images and checking placement.

## Creating PDFs

- Prefer `reportlab.platypus` for text-heavy documents and tables; prefer `reportlab.pdfgen.canvas` for precise drawing.
- Avoid Unicode subscript and superscript glyphs with ReportLab built-in fonts. Use `Paragraph` markup such as `H<sub>2</sub>O` or embed a font that supports the glyphs.
- Embed fonts when portability matters, especially for non-Latin text or symbols.

## Verification Checklist

- Run `qpdf --check` on generated PDFs when `qpdf` is available.
- Compare page counts between input and output for transformations that should preserve pages.
- Render representative pages when layout, overlays, rotations, watermarks, or OCR quality matter.
- Confirm encryption/decryption behavior with a reader or `qpdf --show-encryption` when passwords or permissions are involved.
- Review metadata and attachments if the PDF may contain sensitive information.

## Vulnerability Checklist

- **License risk**: Do not copy proprietary PDF skill text, scripts, or assets into this skill. Keep this file original or based on permissively licensed sources.
- **Parser risk**: PDF parsers can have memory-safety bugs. Prefer patched tools, avoid opening untrusted PDFs in GUI viewers, and process suspicious files in a constrained workspace.
- **Command injection**: Never interpolate user-provided paths, passwords, or page ranges into shell strings.
- **Destructive output**: Avoid `--replace-input`, in-place edits, broad globs, and cleanup commands without explicit confirmation.
- **Credential exposure**: Do not place passwords in committed files, logs, screenshots, or final responses.
- **Data exfiltration**: Avoid external OCR/conversion APIs unless explicitly approved.
- **Malicious content**: Do not activate PDF actions, attachments, embedded media, or links.
- **Temporary files**: Treat rendered pages and OCR text as sensitive; store them locally and clean them up when appropriate.
