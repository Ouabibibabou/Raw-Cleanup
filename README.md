# RAW Photo Cleanup

A Windows batch script for photographers who keep JPEG exports under the same base names as their original RAW files. It checks only the files directly inside the two folders you select, not their subfolders. No installation or PowerShell is required.

**Back up your originals first.** Confirming the folder paths starts the cleanup. Unmatched files are deleted without going to the Recycle Bin. There is no preview, undo, or second confirmation.

## Usage

1. Double-click `raw-cleanup.bat`.
2. Enter or drag in the folder containing the final `.jpg` or `.jpeg` exports.
3. Enter or drag in the folder containing the original RAW files.
4. Check both paths. Enter `Y` to proceed or `N` to cancel.

For example, `DSC_0123.jpg` keeps `DSC_0123.NEF` and `DSC_0123.xmp`. An export named `DSC_0123-edit.jpg` does **not** match those originals. If the JPEG folder is empty of JPEGs, the script stops. If it contains JPEGs but none of their names match, all supported files in the RAW folder are candidates for deletion.

Supported extensions in the RAW folder: `.arw`, `.cr2`, `.cr3`, `.dng`, `.nef`, `.nrw`, `.orf`, `.raf`, `.rw2`, `.pef`, `.srw`, and `.xmp`. XMP sidecars follow the same deletion rule as the photos.

## Known limitations

- Avoid paths and filenames containing `!`: batch delayed expansion can change how these names are read.
- The final deletion count includes attempted deletions. Check the output for warnings about files that could not be deleted.
