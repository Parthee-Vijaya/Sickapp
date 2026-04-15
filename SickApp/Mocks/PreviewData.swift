import Foundation

enum PreviewData {
    static let manager = Manager(
        id: "mgr-001",
        displayName: "Anders Jensen",
        givenName: "Anders",
        mail: "anders.jensen@organisation.dk",
        jobTitle: "Teamleder",
        photoData: nil
    )

    static let employees: [Employee] = [
        Employee(id: "emp-001", displayName: "Maria Nielsen", givenName: "Maria", surname: "Nielsen",
                 mail: "maria.nielsen@organisation.dk", jobTitle: "Socialrådgiver",
                 mobilePhone: "+45 12345678", department: "Socialafdelingen", photoData: nil),
        Employee(id: "emp-002", displayName: "Peter Hansen", givenName: "Peter", surname: "Hansen",
                 mail: "peter.hansen@organisation.dk", jobTitle: "Sagsbehandler",
                 mobilePhone: "+45 23456789", department: "Socialafdelingen", photoData: nil),
        Employee(id: "emp-003", displayName: "Sofia Andersen", givenName: "Sofia", surname: "Andersen",
                 mail: "sofia.andersen@organisation.dk", jobTitle: "Pædagog",
                 mobilePhone: "+45 34567890", department: "Børn og Unge", photoData: nil),
        Employee(id: "emp-004", displayName: "Lars Christensen", givenName: "Lars", surname: "Christensen",
                 mail: "lars.christensen@organisation.dk", jobTitle: "IT-konsulent",
                 mobilePhone: "+45 45678901", department: "IT-afdelingen", photoData: nil),
        Employee(id: "emp-005", displayName: "Emma Pedersen", givenName: "Emma", surname: "Pedersen",
                 mail: "emma.pedersen@organisation.dk", jobTitle: "Administrativ medarbejder",
                 mobilePhone: "+45 56789012", department: "Administration", photoData: nil),
    ]

    static let teamGroups: [TeamGroup] = [
        TeamGroup(id: "grp-001", displayName: "Socialteamet", mail: "socialteam@organisation.dk",
                  members: Array(employees.prefix(3))),
        TeamGroup(id: "grp-002", displayName: "IT-teamet", mail: "it-team@organisation.dk",
                  members: Array(employees.suffix(2))),
    ]

    static let absenceRecords: [AbsenceRecord] = [
        AbsenceRecord(
            id: "abs-001", employeeId: "emp-001", employeeName: "Maria Nielsen",
            managerId: "mgr-001", managerName: "Anders Jensen",
            absenceType: .sygdom, duration: .fullDay,
            startDate: Date(), endDate: nil, customTypeName: nil,
            comment: "Ringet ind syg kl. 7:30", teamGroupId: "grp-001",
            notificationSent: true, status: .active, createdAt: Date()
        ),
        AbsenceRecord(
            id: "abs-002", employeeId: "emp-003", employeeName: "Sofia Andersen",
            managerId: "mgr-001", managerName: "Anders Jensen",
            absenceType: .barnSygedag, duration: .fullDay,
            startDate: Date(), endDate: nil, customTypeName: nil,
            comment: nil, teamGroupId: "grp-001",
            notificationSent: true, status: .active, createdAt: Date()
        ),
        AbsenceRecord(
            id: "abs-003", employeeId: "emp-002", employeeName: "Peter Hansen",
            managerId: "mgr-001", managerName: "Anders Jensen",
            absenceType: .sygdom, duration: .fullDay,
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            customTypeName: nil, comment: "Influenza", teamGroupId: "grp-001",
            notificationSent: true, status: .ended,
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        ),
        AbsenceRecord(
            id: "abs-004", employeeId: "emp-004", employeeName: "Lars Christensen",
            managerId: "mgr-001", managerName: "Anders Jensen",
            absenceType: .andet, duration: .morning,
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            customTypeName: "Tandlæge", comment: nil, teamGroupId: "grp-002",
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
