import SwiftUI

struct SettingsPrivacyCardView: View {
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                SettingsBulletRow(
                    iconName: "checkmark.shield.fill",
                    title: "Permissions are respected",
                    description: "If a permission is denied, that trigger source is paused until the user re-enables it."
                )
                SettingsBulletRow(
                    iconName: "mappin.and.ellipse",
                    title: "Location settings are scoped",
                    description: "Location preferences only affect POI categories, not sample places."
                )
                SettingsBulletRow(
                    iconName: "calendar.badge.exclamationmark",
                    title: "Calendar reminders honor real events",
                    description: "Calendar preferences use real events, not dummy schedules."
                )
            }
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
