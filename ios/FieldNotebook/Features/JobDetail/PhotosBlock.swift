import SwiftUI

/// "Zdjęcia" — list of photo proof entries for the current job. Shows a
/// compact placeholder per upload (we don't yet keep image bytes after upload,
/// so each row is description + size + timestamp). Used only when the job is
/// not in `pending` state.
struct PhotosBlock: View {
    let photos: [PhotoDTO]
    let canAdd: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
                .padding(.bottom, 16)
            HStack {
                SectionLabel(text: "Zdjęcia")
                Spacer()
                if !photos.isEmpty {
                    Text("\(photos.count)")
                        .font(.sans(.semibold, size: 13))
                        .foregroundStyle(Color.muted)
                }
            }
            .padding(.bottom, 12)

            if photos.isEmpty {
                emptyState
            } else {
                VStack(spacing: 8) {
                    ForEach(photos) { photo in
                        photoRow(photo)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var emptyState: some View {
        Text(canAdd
             ? "Brak zdjęć. Dodaj raport zanim zakończysz."
             : "Brak zdjęć z tego zlecenia.")
            .font(.bodyText).foregroundStyle(Color.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
    }

    private func photoRow(_ photo: PhotoDTO) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm).fill(Color.mistDeep)
                IconView(name: .check, size: 18).foregroundStyle(Color.statusDone)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(photo.description.isEmpty ? "Bez opisu" : photo.description)
                    .font(.sans(.semibold, size: 15))
                    .foregroundStyle(Color.titleInk)
                    .lineLimit(2)
                Text(formattedSize(photo.sizeBytes))
                    .font(.mono(.regular, size: 12))
                    .foregroundStyle(Color.muted)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func formattedSize(_ bytes: Int) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        let kb = Double(bytes) / 1024
        if kb < 1024 { return String(format: "%.0f kB", kb) }
        return String(format: "%.1f MB", kb / 1024)
    }
}
