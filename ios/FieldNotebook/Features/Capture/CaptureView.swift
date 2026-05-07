import SwiftUI

struct CaptureView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let jobId: String

    @State private var image: UIImage?
    @State private var description = ""
    @State private var pickerOpen = false
    @State private var phase: Phase = .idle
    @FocusState private var descriptionFocused: Bool

    enum Phase: Equatable {
        case idle
        case uploading
        case finalizing
        case failed(String)
    }

    var body: some View {
        VStack(spacing: 0) {
            DetailTopBar(onBack: { dismiss() },
                         ticketId: store.jobs.first(where: { $0.id == jobId })?.ticketId ?? "—",
                         syncState: store.syncState)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Dokumentacja").font(.headline).foregroundStyle(Color.titleInk)
                    if let image {
                        photoPreview(image)
                    } else {
                        photoPickerButton
                    }
                    descriptionField
                    if case .failed(let message) = phase {
                        errorBanner(message)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.cream)
            .safeAreaInset(edge: .bottom) {
                BottomCTA(title: ctaTitle,
                          iconName: ctaIcon,
                          enabled: ctaEnabled,
                          loading: ctaLoading) {
                    Task { await submit() }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $pickerOpen) { PhotoPicker(image: $image) }
    }

    // MARK: - Subviews

    private func photoPreview(_ image: UIImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable().scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            Button(action: { self.image = nil }) {
                IconView(name: .plus, size: 18)
                    .rotationEffect(.degrees(45))
                    .foregroundStyle(Color.inkOnSignal)
                    .padding(8)
                    .background(Color.bodyInk.opacity(0.78), in: Circle())
            }
            .padding(8)
            .accessibilityLabel("Usuń zdjęcie")
        }
    }

    private var photoPickerButton: some View {
        Button { pickerOpen = true } label: {
            VStack(spacing: 12) {
                IconView(name: .plus, size: 32).foregroundStyle(Color.signal)
                Text("Wybierz zdjęcie").font(.titleText).foregroundStyle(Color.bodyInk)
                Text("Aparat lub biblioteka")
                    .font(.labelSmall).foregroundStyle(Color.muted)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.lg))
        }
    }

    private var descriptionField: some View {
        TextField("Krótki opis (np. wymieniono baterię)", text: $description, axis: .vertical)
            .font(.bodyText)
            .lineLimit(3...6)
            .focused($descriptionFocused)
            .submitLabel(.done)
            .onSubmit { descriptionFocused = false }
            .padding(14)
            .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            IconView(name: .alertTriangle, size: 16).foregroundStyle(Color.statusUrgent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Nie udało się wysłać")
                    .font(.sans(.semibold, size: 14))
                    .foregroundStyle(Color.statusUrgent)
                Text(message)
                    .font(.bodyText)
                    .foregroundStyle(Color.bodyInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.statusUrgentSoft, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    // MARK: - CTA state

    private var ctaTitle: String {
        switch phase {
        case .idle:                return "Dodaj raport i zakończ"
        case .uploading:           return "Wysyłanie zdjęcia…"
        case .finalizing:          return "Kończenie zlecenia…"
        case .failed:              return "Spróbuj ponownie"
        }
    }

    private var ctaIcon: IconName? {
        switch phase {
        case .idle:                return .check
        case .uploading, .finalizing: return nil
        case .failed:              return .refreshCw
        }
    }

    private var ctaEnabled: Bool {
        if image == nil || description.isEmpty { return false }
        switch phase {
        case .uploading, .finalizing: return false
        default:                       return true
        }
    }

    private var ctaLoading: Bool {
        switch phase {
        case .uploading, .finalizing: return true
        default:                       return false
        }
    }

    // MARK: - Submit

    private func submit() async {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return }
        descriptionFocused = false
        phase = .uploading
        let result = await store.uploadPhoto(
            jobId: jobId, image: data,
            description: description, mimeType: "image/jpeg"
        )
        switch result {
        case .uploaded, .queued:
            phase = .finalizing
            await store.completeJob(jobId)
            dismiss()
        case .failed(let error):
            phase = .failed(error.userMessagePolish)
        }
    }
}
