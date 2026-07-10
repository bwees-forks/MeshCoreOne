import MC1Services
import SwiftUI
import UIKit

/// Fragment-level view that renders the inline image as its own sub-bubble
/// below the text box, mirroring the chat map thumbnail. The card is a
/// fixed-height box (`InlineImageLayout`) whose width tracks the image aspect
/// but is clamped so a wide image crops rather than resizing the row. The box
/// is reserved before the bytes arrive using `InlineImage.cachedAspect`
/// (falling back to 16:9), so the bubble does not jump when the image loads.
struct InlineImageFragmentView: View {
  let inlineImage: InlineImage
  let isOutgoing: Bool
  let imageResolver: (ImageReference) -> UIImage?
  let onTap: () -> Void
  let onRetry: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private static let crossFadeDuration: Double = 0.2
  private static let retryIconSpacing: CGFloat = 8
  private static let retryForegroundOpacity: Double = 0.7

  private var aspect: Double {
    inlineImage.cachedAspect ?? RichPreviewMetrics.fallbackAspect
  }

  var body: some View {
    ZStack {
      PreviewSkeleton(cornerRadius: InlineImageLayout.cornerRadius)
        .opacity(isLoaded ? 0 : 1)

      loadedLayer
        .opacity(isLoaded ? 1 : 0)

      if case .failed = inlineImage.state {
        retryLayer
      }
    }
    .frame(
      width: InlineImageLayout.width(forAspect: aspect),
      height: InlineImageLayout.height
    )
    .clipShape(.rect(cornerRadius: InlineImageLayout.cornerRadius))
    .animation(
      reduceMotion ? nil : .easeOut(duration: Self.crossFadeDuration),
      value: isLoaded
    )
  }

  private var isLoaded: Bool {
    if case let .loaded(ref, _) = inlineImage.state,
       imageResolver(ref) != nil {
      return true
    }
    return false
  }

  @ViewBuilder
  private var loadedLayer: some View {
    if case let .loaded(ref, isGIF) = inlineImage.state,
       let image = imageResolver(ref) {
      InlineImageView(
        image: image,
        isGIF: isGIF,
        autoPlayGIFs: inlineImage.autoPlayGIFs,
        isEmbedded: true,
        onTap: onTap
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  private var retryLayer: some View {
    Button(action: onRetry) {
      ZStack {
        RoundedRectangle(cornerRadius: InlineImageLayout.cornerRadius, style: .continuous)
          .fill(Color(.tertiarySystemFill))
        HStack(spacing: Self.retryIconSpacing) {
          Image(systemName: "arrow.clockwise")
            .foregroundStyle(isOutgoing ? .white.opacity(Self.retryForegroundOpacity) : .secondary)
          Text(L10n.Chats.Chats.InlineImage.tapToRetry)
            .font(.subheadline)
            .foregroundStyle(isOutgoing ? .white.opacity(Self.retryForegroundOpacity) : .secondary)
        }
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(L10n.Chats.Chats.InlineImage.failedLabel)
    .accessibilityHint(L10n.Chats.Chats.InlineImage.retryHint)
  }
}
