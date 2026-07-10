import Foundation
import MC1Services

/// The single source of truth for which fragments render inside the colored
/// bubble box versus below it.
///
/// Placement rule: `.text` fills the box (`BubbleFragmentStack`). `.inlineImage`
/// renders as its own fixed-size card immediately below the box, ahead of the
/// siblings, so it stays adjacent to the text it accompanies. Every other kind
/// renders as a sibling beneath that (`UnifiedMessageBubble`), preserving
/// document order. Adding a fragment kind is one decision here, not a fan-out
/// across the bubble view bodies.
///
/// This is render partitioning, not model data: it is a pure function of
/// `item.content`, computed once in `MessageBubbleView.body` and passed down as
/// a plain value. It is never stored on `MessageItem` and never participates in
/// any bubble view's `==`, so the item-only Equatable seam stays intact.
struct FragmentLayout {
  /// The single text fragment that fills the bubble box, if any.
  let textPayload: MessageTextPayload?

  /// The single inline image attached to the bubble box, if any.
  let inlineImage: InlineImage?

  /// Fragments rendered below the box, in document order. Excludes the
  /// box-resident text and inline image.
  let siblings: [MessageFragment]

  init(content: [MessageFragment]) {
    var textPayload: MessageTextPayload?
    var inlineImage: InlineImage?
    var siblings: [MessageFragment] = []

    for fragment in content {
      switch fragment {
      case let .text(payload):
        if textPayload == nil { textPayload = payload }
      case let .inlineImage(image):
        if inlineImage == nil { inlineImage = image }
      case .linkPreview, .mapPreview, .malwareWarning, .reactionSummary:
        siblings.append(fragment)
      }
    }

    self.textPayload = textPayload
    self.inlineImage = inlineImage
    self.siblings = siblings
  }
}
