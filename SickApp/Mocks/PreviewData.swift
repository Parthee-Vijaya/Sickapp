import Foundation

enum PreviewData {
    static let manager = Manager(
        id: "mgr-001",
        displayName: "Anne Dandanell",
        givenName: "Anne",
        mail: "anne.dandanell@kalundborg.dk",
        jobTitle: "Chef for IT og Digitalisering",
        photoData: nil
    )

    // MARK: - Employees by team

    static let ledelse: [Employee] = [
        Employee(id: "emp-001", displayName: "Claes Jensen", givenName: "Claes", surname: "Jensen",
                 mail: "claes.jensen@kalundborg.dk", jobTitle: "Leder",
                 mobilePhone: nil, department: "Ledelse", photoData: nil),
    ]

    static let stab: [Employee] = [
        Employee(id: "emp-002", displayName: "Bjarne Østergaard", givenName: "Bjarne", surname: "Østergaard",
                 mail: "bjarne.ostergaard@kalundborg.dk", jobTitle: "Konsulent",
                 mobilePhone: nil, department: "Stab", photoData: nil),
        Employee(id: "emp-003", displayName: "Charlotte Højlund", givenName: "Charlotte", surname: "Højlund",
                 mail: "charlotte.hojlund@kalundborg.dk", jobTitle: "Konsulent",
                 mobilePhone: nil, department: "Stab", photoData: nil),
    ]

    static let rpaTeam: [Employee] = [
        Employee(id: "emp-004", displayName: "Rasmus Pedersen", givenName: "Rasmus", surname: "Pedersen",
                 mail: "rasmus.pedersen@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
        Employee(id: "emp-005", displayName: "Marie Matthiesen", givenName: "Marie", surname: "Matthiesen",
                 mail: "marie.matthiesen@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
        Employee(id: "emp-006", displayName: "Caydaruus Warsame", givenName: "Caydaruus", surname: "Warsame",
                 mail: "caydaruus.warsame@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
        Employee(id: "emp-007", displayName: "Tobias Hammer", givenName: "Tobias", surname: "Hammer",
                 mail: "tobias.hammer@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
        Employee(id: "emp-008", displayName: "Parthee Vijayakumar", givenName: "Parthee", surname: "Vijayakumar",
                 mail: "parthee.vijayakumar@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
        Employee(id: "emp-009", displayName: "Anita Lauridsen", givenName: "Anita", surname: "Lauridsen",
                 mail: "anita.lauridsen@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
        Employee(id: "emp-010", displayName: "Maria Schlundt", givenName: "Maria", surname: "Schlundt",
                 mail: "maria.schlundt@kalundborg.dk", jobTitle: "RPA-udvikler",
                 mobilePhone: nil, department: "RPA-Teamet", photoData: nil),
    ]

    static let helpdesk: [Employee] = [
        Employee(id: "emp-011", displayName: "Helle Nielsen", givenName: "Helle", surname: "Nielsen",
                 mail: "helle.nielsen@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-012", displayName: "Martin Rather", givenName: "Martin", surname: "Rather",
                 mail: "martin.rather@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-013", displayName: "Mads Holmgaard", givenName: "Mads", surname: "Holmgaard",
                 mail: "mads.holmgaard@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-014", displayName: "Jesper Thrane", givenName: "Jesper", surname: "Thrane",
                 mail: "jesper.thrane@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-015", displayName: "Brian Helbo", givenName: "Brian", surname: "Helbo",
                 mail: "brian.helbo@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-016", displayName: "Daniel Krarup", givenName: "Daniel", surname: "Krarup",
                 mail: "daniel.krarup@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-017", displayName: "Henrik K. Benno", givenName: "Henrik", surname: "Benno",
                 mail: "henrik.benno@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-018", displayName: "Marcus Christensen", givenName: "Marcus", surname: "Christensen",
                 mail: "marcus.christensen@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-019", displayName: "Mikkel Hass", givenName: "Mikkel", surname: "Hass",
                 mail: "mikkel.hass@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
        Employee(id: "emp-020", displayName: "Jeppe Mortensen", givenName: "Jeppe", surname: "Mortensen",
                 mail: "jeppe.mortensen@kalundborg.dk", jobTitle: "Helpdesk-medarbejder",
                 mobilePhone: nil, department: "Helpdesk", photoData: nil),
    ]

    static let drift: [Employee] = [
        Employee(id: "emp-021", displayName: "Søren Kristensen", givenName: "Søren", surname: "Kristensen",
                 mail: "soren.kristensen@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-022", displayName: "Jesper Larsen", givenName: "Jesper", surname: "Larsen",
                 mail: "jesper.larsen@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-023", displayName: "Peter Ahlgren", givenName: "Peter", surname: "Ahlgren",
                 mail: "peter.ahlgren@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-024", displayName: "Jimmi Krogh", givenName: "Jimmi", surname: "Krogh",
                 mail: "jimmi.krogh@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-025", displayName: "Emil Lind", givenName: "Emil", surname: "Lind",
                 mail: "emil.lind@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-026", displayName: "Mikkel Sørensen", givenName: "Mikkel", surname: "Sørensen",
                 mail: "mikkel.sorensen@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-027", displayName: "Mads Eriksen", givenName: "Mads", surname: "Eriksen",
                 mail: "mads.eriksen@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
        Employee(id: "emp-028", displayName: "Peter Meyland", givenName: "Peter", surname: "Meyland",
                 mail: "peter.meyland@kalundborg.dk", jobTitle: "Driftsmedarbejder",
                 mobilePhone: nil, department: "Drift", photoData: nil),
    ]

    static let employees: [Employee] = ledelse + stab + rpaTeam + helpdesk + drift

    static let teamGroups: [TeamGroup] = [
        TeamGroup(id: "grp-001", displayName: "Ledelse", mail: "ledelse.itd@kalundborg.dk",
                  members: ledelse),
        TeamGroup(id: "grp-002", displayName: "Stab", mail: "stab.itd@kalundborg.dk",
                  members: stab),
        TeamGroup(id: "grp-003", displayName: "RPA-Teamet", mail: "rpa@kalundborg.dk",
                  members: rpaTeam),
        TeamGroup(id: "grp-004", displayName: "Helpdesk", mail: "helpdesk@kalundborg.dk",
                  members: helpdesk),
        TeamGroup(id: "grp-005", displayName: "Drift", mail: "drift@kalundborg.dk",
                  members: drift),
    ]

    static let absenceRecords: [AbsenceRecord] = [
        AbsenceRecord(
            id: "abs-001", employeeId: "emp-005", employeeName: "Marie Matthiesen",
            managerId: "mgr-001", managerName: "Anne Dandanell",
            absenceType: .sygdom, duration: .fullDay,
            startDate: Date(), endDate: nil, customTypeName: nil,
            comment: "Ringet ind syg kl. 7:30", teamGroupId: "grp-003",
            notificationSent: true, status: .active, createdAt: Date()
        ),
        AbsenceRecord(
            id: "abs-002", employeeId: "emp-011", employeeName: "Helle Nielsen",
            managerId: "mgr-001", managerName: "Anne Dandanell",
            absenceType: .barnSygedag, duration: .fullDay,
            startDate: Date(), endDate: nil, customTypeName: nil,
            comment: nil, teamGroupId: "grp-004",
            notificationSent: true, status: .active, createdAt: Date()
        ),
        AbsenceRecord(
            id: "abs-003", employeeId: "emp-021", employeeName: "Søren Kristensen",
            managerId: "mgr-001", managerName: "Anne Dandanell",
            absenceType: .sygdom, duration: .fullDay,
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            customTypeName: nil, comment: "Influenza", teamGroupId: "grp-005",
            notificationSent: true, status: .ended,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        ),
        AbsenceRecord(
            id: "abs-004", employeeId: "emp-014", employeeName: "Jesper Thrane",
            managerId: "mgr-001", managerName: "Anne Dandanell",
            absenceType: .andet, duration: .morning,
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            customTypeName: "Tandlæge", comment: nil, teamGroupId: "grp-004",
            notificationSent: false, status: .ended,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
    ]

    static let absenceStats = AbsenceStats(
        totalDays: 12,
        totalRecords: 8,
        byType: [
            .init(type: .sygdom, count: 5, days: 8),
            .init(type: .barnSygedag, count: 2, days: 3),
            .init(type: .andet, count: 1, days: 1),
        ],
        monthlyTrend: [
            .init(month: "Nov", count: 3, days: 5),
            .init(month: "Dec", count: 2, days: 3),
            .init(month: "Jan", count: 4, days: 6),
            .init(month: "Feb", count: 1, days: 2),
            .init(month: "Mar", count: 3, days: 4),
            .init(month: "Apr", count: 2, days: 3),
        ],
        previousPeriodDays: 10
    )

    static let activeAbsences: [AbsenceRecord] = absenceRecords.filter { $0.isActive }
}
