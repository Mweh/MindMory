import SwiftUI

struct SettingsPrivacyCardView: View {
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                sectionTitle(
                    title: "Privacy & behavior notes",
                    subtitle: "These settings show real permissions and reminder preferences."
                )

                SettingsBulletRow(
                    iconName: "checkmark.shield.fill",
                    text: "If a permission is denied, that trigger source is paused until the user re-enables it."
                )
                SettingsBulletRow(
                    iconName: "mappin.and.ellipse",
                    text: "Location preferences only affect POI categories, not sample places."
                )
                SettingsBulletRow(
                    iconName: "calendar.badge.exclamationmark",
                    text: "Calendar preferences use real events, not dummy schedules."
                )
            }
        }
    }

    private func sectionTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
            Text(title)
                .font(MindMoryTypography.titleMedium)

            Text(subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }
}

#if DEBUG
struct SettingsPrivacyCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPrivacyCardView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
