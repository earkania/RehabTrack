/// Safety limits applied when reading and validating backup archives.
///
/// These guard against decompression-bomb and oversized-archive abuse while
/// leaving generous headroom for future backups that include medical images,
/// lab-analysis PDFs and other large documents.
///
/// Rationale for the chosen values:
///
/// - **Archive file (compressed) size** 2 GiB — the reader loads the archive
///   into memory once to inspect the ZIP central directory, so the on-disk
///   size must stay bounded.
/// - **Entry count** 5000 — comfortably above any realistic photo/attachment
///   count while bounding directory-processing work.
/// - **Per-entry uncompressed size** 512 MiB — allows large documents/PDFs
///   while keeping a single in-memory decompression reasonable on mobile.
/// - **Total uncompressed size** 4 GiB — a whole-backup budget that future
///   Lab Analysis backups will not hit.
/// - **Compression ratio** 200:1 — flags classic decompression bombs (e.g. a
///   few KiB of compressed data expanding to gigabytes).
/// - **Manifest / preferences size** 1 MiB each — manifests and settings are
///   small by nature; anything larger is almost certainly hostile or corrupt.
class BackupLimits {
  BackupLimits._();

  static const int maxArchiveFileBytes = 2 * 1024 * 1024 * 1024;

  static const int maxEntryCount = 5000;

  static const int maxManifestBytes = 1024 * 1024;

  static const int maxPreferencesBytes = 1024 * 1024;

  static const int maxPerEntryUncompressedBytes = 512 * 1024 * 1024;

  static const int maxTotalUncompressedBytes = 4 * 1024 * 1024 * 1024;

  static const int maxCompressionRatio = 200;
}
