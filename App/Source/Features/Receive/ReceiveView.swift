import SwiftUI
import CoreImage.CIFilterBuiltins

/// Fake receive screen: renders a genuine QR code that encodes the fake address
/// string. Scanning it with any QR reader just yields the address text.
struct ReceiveView: View {
    @EnvironmentObject private var store: DemoStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                qrCode
                    .frame(width: 240, height: 240)
                    .padding(14)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 4)

                VStack(spacing: 4) {
                    Text("This address is invented")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.15, blue: 0.25))
                    Text("Anyone who sends real funds to it loses them forever.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 6) {
                    Text("FAKE ADDRESS")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(store.walletAddress)
                        .font(.system(.footnote, design: .monospaced).weight(.medium))
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 14))

                Button {
                    UIPasteboard.general.string = store.walletAddress
                } label: {
                    Label("Copy fake address", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)

                Spacer(minLength: 0)
            }
            .padding(20)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Receive (fake)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var qrCode: some View {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(store.walletAddress.utf8)
        filter.correctionLevel = "M"

        var image: UIImage?
        if let output = filter.outputImage,
           let cg = context.createCGImage(output, from: output.extent) {
            image = UIImage(cgImage: cg)
        }

        return Group {
            if let image {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
