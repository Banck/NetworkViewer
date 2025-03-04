struct OperationData {
    var success: Bool
    var status: String
    var url: String
    var method: String
    var startTime: String
    var endTime: String
    var duration: String?
    var sectionsData: [SectionData]
    var isWeb: Bool
}

extension OperationData {

    struct SectionData: RowIdentifible {

        var id: String
        let title: String?
        let cellData: [HDetailedRow.Data]

        init(id: String, title: String?, cellData: [HDetailedRow.Data]) {
            self.id = id
            self.title = title
            self.cellData = cellData
        }
    }
}
