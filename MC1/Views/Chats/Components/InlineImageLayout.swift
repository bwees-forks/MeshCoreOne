import CoreGraphics

/// Fixed geometry for the inline-image sub-bubble, mirroring `MapSnapshotLayout`.
/// The height is a constant so the bubble reserves the same vertical space
/// before and after the bytes arrive — the flipped message table depends on
/// rows not resizing after layout. The width tracks the image aspect but is
/// clamped to `[minWidth, maxWidth]`; when the natural width would overflow the
/// row the image is cropped (`scaledToFill`) rather than shrinking the box.
enum InlineImageLayout {
  static let height: CGFloat = 200
  static let maxWidth: CGFloat = 260
  static let minWidth: CGFloat = 100
  static let cornerRadius: CGFloat = RichPreviewMetrics.cornerRadius

  /// Width for a fixed-height card holding an image of the given
  /// width-over-height `aspect`, clamped so a very wide image crops
  /// horizontally and a very tall one crops vertically.
  static func width(forAspect aspect: Double) -> CGFloat {
    let natural = height * CGFloat(aspect)
    return min(maxWidth, max(minWidth, natural))
  }
}
