import Foundation

enum PreviewData {
    static let aromaMemory = Memory(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "Aroma Coffee",
        subtitle: "Great conversations, the laughter, and the little moments in between.",
        dateText: "Today, 10:23 AM",
        locationName: "Aroma Coffee",
        imageName: "memory-aroma",
        journalText: "We stayed longer than planned, and that made it even better.",
        isFavorite: true,
        tags: ["Location", "Friends"]
    )

    static let holidayMemory = Memory(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        title: "Academy Lunch",
        subtitle: "A warm table, familiar voices, and a day worth keeping.",
        dateText: "Monday, May 12",
        locationName: "Apple Developer Academy",
        imageName: "memory-academy",
        journalText: nil,
        isFavorite: false,
        tags: ["Public Holiday", "Event"]
    )

    static let eveningMemory = Memory(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        title: "Evening Walk",
        subtitle: "The quiet after a full day made everything feel softer.",
        dateText: "Yesterday, 6:41 PM",
        locationName: "City Garden",
        imageName: "memory-evening",
        journalText: "Fresh air helped me remember the day clearly.",
        isFavorite: false,
        tags: ["Recent Activity"]
    )

    static let memories = [aromaMemory, holidayMemory, eveningMemory]

    static func albumSectionPhoto(from urlString: String) -> AlbumPhoto? {
        AlbumPhoto.from(urlString: urlString)
    }

    static let graduationAlbumSections: [MemoryAlbumSection] = {
        let graduatePortrait = albumSectionPhoto(from: "https://images.unsplash.com/photo-1636231945376-3d40fdcbc462?auto=format&fit=crop&w=800&q=80")
        let capToss = albumSectionPhoto(from: "https://images.unsplash.com/photo-1627556704290-2b1f5853ff78?auto=format&fit=crop&w=800&q=80")
        let stageCheers = albumSectionPhoto(from: "https://images.unsplash.com/photo-1623461487986-9400110de28e?auto=format&fit=crop&w=800&q=80")
        let diplomaCloseup = albumSectionPhoto(from: "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=800&q=80")
        let reception = albumSectionPhoto(from: "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?auto=format&fit=crop&w=800&q=80")
        let crowdShot = albumSectionPhoto(from: "https://images.unsplash.com/photo-1623945352596-36d5d9f21f70?auto=format&fit=crop&w=800&q=80")
        let familyMoment = albumSectionPhoto(from: "https://images.unsplash.com/photo-1498079022511-d15614cb1c02?auto=format&fit=crop&w=800&q=80")
        let stageAudience = albumSectionPhoto(from: "https://images.unsplash.com/photo-1496469888073-80de7e952517?auto=format&fit=crop&w=800&q=80")
        let graduateCap = albumSectionPhoto(from: "https://images.unsplash.com/photo-1607013407627-6ee814329547?auto=format&fit=crop&w=800&q=80")
        let ceremonyWide = albumSectionPhoto(from: "https://images.unsplash.com/photo-1633734973050-d6499a977c17?auto=format&fit=crop&w=800&q=80")
        let finalCheers = albumSectionPhoto(from: "https://images.unsplash.com/photo-1658235081562-a7f50e7e05b6?auto=format&fit=crop&w=800&q=80")
        let capDetail = albumSectionPhoto(from: "https://images.unsplash.com/photo-1525921429624-479b6a26d84d?auto=format&fit=crop&w=800&q=80")
        let celebrationWide = albumSectionPhoto(from: "https://images.unsplash.com/photo-1639503667014-6533f3f34831?auto=format&fit=crop&w=800&q=80")
        let diplomaShot = albumSectionPhoto(from: "https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?auto=format&fit=crop&w=800&q=80")
        let groupPhoto = albumSectionPhoto(from: "https://images.unsplash.com/photo-1619279302118-43033660826a?auto=format&fit=crop&w=800&q=80")

        return [
            MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                templateVariant: 0,
                blockType: .titleAndDescription,
                horizontalAlignment: .leading,
                verticalAlignment: .top,
                isTitleFirst: true,
                title: "Graduation Day",
                description: "The morning began with quiet nerves and ended with cheering, hugs, and the feeling that a new chapter had finally arrived.",
                style: .default
            )),
            MemoryAlbumSection(layoutCount: 1, layoutVariant: 0, photos: [graduatePortrait]),
            MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                templateVariant: 1,
                blockType: .descriptionOnly,
                horizontalAlignment: .leading,
                verticalAlignment: .center,
                isTitleFirst: false,
                title: "",
                description: "Walking across the stage felt like a bridge between long nights of studying and the bright, uncertain road ahead.",
                style: .default
            )),
            MemoryAlbumSection(layoutCount: 2, layoutVariant: 0, photos: [capToss, stageCheers]),
            MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                templateVariant: 0,
                blockType: .titleAndDescription,
                horizontalAlignment: .center,
                verticalAlignment: .top,
                isTitleFirst: true,
                title: "The moment that mattered most",
                description: "It wasn’t the tassels or speeches alone — it was the shared relief, the surprise laughter, and the people who stayed by our side.",
                style: .default
            )),
            MemoryAlbumSection(layoutCount: 3, layoutVariant: 2, photos: [diplomaCloseup, ceremonyWide, reception]),
            MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                templateVariant: 2,
                blockType: .titleOnly,
                horizontalAlignment: .leading,
                verticalAlignment: .center,
                isTitleFirst: true,
                title: "Family cheers",
                description: "",
                style: .default
            )),
            MemoryAlbumSection(layoutCount: 4, layoutVariant: 0, photos: [stageAudience, graduateCap, crowdShot, familyMoment]),
            MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                templateVariant: 1,
                blockType: .descriptionOnly,
                horizontalAlignment: .leading,
                verticalAlignment: .center,
                isTitleFirst: false,
                title: "",
                description: "The day ended with quiet conversation, warm congratulations, and a confident sense that the journey had only just begun.",
                style: .default
            )),
            MemoryAlbumSection(layoutCount: 5, layoutVariant: 0, photos: [finalCheers, capDetail, celebrationWide, diplomaShot, groupPhoto])
        ]
    }()

    static let graduationAlbum = Album(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
        name: "Graduation Memories",
        note: "A small collection of the ceremony, family, and the excitement of turning the page.",
        photos: [
            AlbumPhoto.from(urlString: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80"),
            AlbumPhoto.from(urlString: "https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=800&q=80"),
            AlbumPhoto.from(urlString: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80"),
            AlbumPhoto.from(urlString: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80"),
            AlbumPhoto.from(urlString: "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80")
        ].compactMap { $0 },
        sections: graduationAlbumSections,
        createdAt: Date(),
        category: .memory
    )

    static let sampleAlbums = [graduationAlbum]

    static let reminder = Reminder(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        title: "This moment looks special.",
        message: "Capture it before it’s gone.",
        context: .location(LocationContext(placeName: "Aroma Coffee", durationText: "Today, 10:23 AM")),
        imageName: "memory-aroma"
    )

    static let triggerSettings = ContextTriggerSettings(
        locationBasedReminders: true,
        publicHolidayReminders: true,
        calendarReminders: true,
        userPatternReminders: false,
        recentActivityReminders: true,
        notificationWordingPreference: "Warm and thoughtful"
    )
}
