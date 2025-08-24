import SwiftUI
// import WidgetKit // ✅ 1. 移除 WidgetKit 的導入

// MARK: - Enums
enum CalendarScope {
    case month
    case week
}

// MARK: - Helper Views

struct MedicalRecordHistoryView: View {
    // ✅ 移除 @State，因為這個視圖應該只接收資料來顯示，而不是自己管理資料狀態
    // 這樣可以讓它更具可複用性
    var records: [MedicalRecord]
    
    var body: some View {
        List(records) { record in
            VStack(alignment: .leading) {
                Text(record.hospital).font(.headline)
                Text("患部: \(record.affectedPart)").font(.subheadline).foregroundColor(.secondary)
                if !record.treatmentContent.isEmpty {
                    Text("治療狀況: \(record.treatmentContent)").font(.caption).foregroundColor(.themeHighlight)
                }
            }
        }.navigationTitle("歷史紀錄")
    }
}

struct Appointment: Identifiable {
    let id: UUID
    var clinicName: String
    var appointmentTime: Date
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var displayDate: Date
    @Binding var scope: CalendarScope
    let appointments: [Appointment]
    
    private var appointmentDates: Set<DateComponents> {
        let calendar = Calendar.current
        return Set(appointments.map { calendar.dateComponents([.year, .month, .day], from: $0.appointmentTime) })
    }
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: { changeDate(by: -1) }) { Image(systemName: "chevron.left") }
                Spacer()
                Text(headerString(from: displayDate)).font(.headline)
                Spacer()
                Button(action: { changeDate(by: 1) }) { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)
            .foregroundColor(.themePrimaryText)
            
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day).font(.caption).frame(maxWidth: .infinity).foregroundColor(.themeSecondaryText)
                }
            }
            
            if scope == .month {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(generateMonthDates(for: displayDate), id: \.self) { date in dayView(for: date) }
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(generateWeekDates(for: displayDate), id: \.self) { date in dayView(for: date).frame(maxWidth: .infinity) }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .animation(.easeInOut, value: displayDate)
    }
    
    @ViewBuilder
    private func dayView(for date: Date) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isCurrentMonth = calendar.isDate(date, equalTo: displayDate, toGranularity: .month)
        let hasAppointment = appointmentDates.contains(calendar.dateComponents([.year, .month, .day], from: date))
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        Button(action: { selectedDate = date }) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .fontWeight(.medium).frame(maxWidth: .infinity, minHeight: 30).padding(4)
                    .background(isToday ? Color.themeHighlight : .clear)
                    .foregroundColor(isToday ? .white : (isCurrentMonth ? .themePrimaryText : .themeSecondaryText.opacity(0.7)))
                    .clipShape(Circle())
                    .overlay(isSelected && !isToday ? Circle().stroke(Color.themeHighlight, lineWidth: 2) : nil)
                if hasAppointment {
                    Circle().fill(Color.themeHighlight).frame(width: 6, height: 6)
                } else {
                    Circle().fill(Color.clear).frame(width: 6, height: 6)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func changeDate(by value: Int) {
        let calendar = Calendar.current
        if scope == .month, let newDate = calendar.date(byAdding: .month, value: value, to: displayDate) {
            displayDate = newDate
        } else if scope == .week, let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: displayDate) {
            displayDate = newDate
        }
    }
    
    private func headerString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateFormat = scope == .month ? "yyyy年 M月" : "yyyy年 M月 d日"
        return formatter.string(from: date)
    }
    
    private func generateMonthDates(for month: Date) -> [Date] {
        let calendar = Calendar.current
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        guard let gridStartDate = calendar.date(byAdding: .day, value: -firstWeekday, to: firstDayOfMonth) else { return [] }
        return (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: gridStartDate) }
    }
    
    private func generateWeekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
}

struct RecordRowView: View {
    let record: MedicalRecord
    var showFullDate: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.hospital).font(.headline)
            HStack {
                Image(systemName: "person.fill")
                Text(record.therapistName)
            }.font(.subheadline)
            HStack {
                Image(systemName: "clock.fill")
                if showFullDate { Text(record.appointmentTime, style: .date) }
                Text(record.appointmentTime, style: .time)
            }.font(.subheadline).foregroundColor(.secondary)
            if !record.treatmentContent.isEmpty {
                HStack {
                    Image(systemName: "pencil.and.scribble")
                    Text(record.treatmentContent).lineLimit(1)
                }.font(.subheadline).foregroundColor(.themeHighlight)
            }
        }
        .padding(.vertical, 5)
    }
}

struct ConsultationRecordListView: View {
    @Binding var records: [MedicalRecord]

    var body: some View {
        List {
            ForEach($records) { $record in
                NavigationLink(destination: AddOrEditRecordView(record: $record, isAppointmentOnly: false)) {
                    RecordRowView(record: record, showFullDate: true)
                }
            }
        }
        .navigationTitle("記錄就診狀況")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Main View
struct MedicalRecordView: View {
    @State private var records: [MedicalRecord] = []
    
    @State private var showingAddSheet = false
    @State private var calendarScope: CalendarScope = .month
    @State private var selectedDate: Date = Date()
    @State private var displayDate: Date = Date()
    
    @State private var newRecord = MedicalRecord()
    
    private var weeklyRecords: [MedicalRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let oneWeekLater = calendar.date(byAdding: .day, value: 7, to: today) else { return [] }
        return records
            .filter { $0.appointmentTime >= today && $0.appointmentTime < oneWeekLater }
            .sorted { $0.appointmentTime < $1.appointmentTime }
    }
    
    private var recordsForToday: [MedicalRecord] {
        let calendar = Calendar.current
        return records
            .filter { calendar.isDateInToday($0.appointmentTime) }
            .sorted { $0.appointmentTime < $1.appointmentTime }
    }
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            NavigationStack {
                List {
                    Section {
                        Picker("日曆範圍", selection: $calendarScope) {
                            Text("月").tag(CalendarScope.month)
                            Text("週").tag(CalendarScope.week)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 5)
                        
                        CalendarView(selectedDate: $selectedDate, displayDate: $displayDate, scope: $calendarScope, appointments: records.map {
                            Appointment(id: $0.id, clinicName: $0.hospital, appointmentTime: $0.appointmentTime)
                        })
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .highPriorityGesture(DragGesture())
                    
                    Section {
                        if recordsForToday.isEmpty {
                            Text("今天沒有預約行程")
                        } else {
                            ForEach(recordsForToday) { record in
                                if let index = records.firstIndex(where: { $0.id == record.id }) {
                                    NavigationLink(destination: AddOrEditRecordView(record: $records[index], isAppointmentOnly: true)) {
                                        RecordRowView(record: record)
                                    }
                                }
                            }
                            .onDelete(perform: deleteTodayRecord)
                        }
                    } header: {
                        Label("今日行程", systemImage: "sun.max.fill").font(.headline).foregroundColor(.themeHighlight)
                    }
                    
                    Section {
                        if weeklyRecords.isEmpty {
                            Text("未來一週沒有預約").foregroundColor(.gray)
                        } else {
                            ForEach(weeklyRecords) { record in
                                if let index = records.firstIndex(where: { $0.id == record.id }) {
                                    NavigationLink(destination: AddOrEditRecordView(record: $records[index], isAppointmentOnly: true)) {
                                        RecordRowView(record: record, showFullDate: true)
                                    }
                                }
                            }
                            .onDelete(perform: deleteWeeklyRecord)
                        }
                    } header: {
                        Label("一週內的醫療行程", systemImage: "forward.fill").font(.headline).foregroundColor(.themeHighlight)
                    }

                    Section {
                        // ✅ 將 `MedicalRecordHistoryView` 的 `records` 參數直接傳入
                        NavigationLink(destination: MedicalRecordHistoryView(records: records)) {
                            Label("記錄就診狀況", systemImage: "pencil.and.scribble")
                                .font(.headline)
                                .foregroundColor(.themeHighlight)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .onChange(of: displayDate) { selectedDate = displayDate }
                .onChange(of: calendarScope) { displayDate = selectedDate }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("行事曆").font(.system(size: 26, weight: .bold)).foregroundColor(.themeHighlight)
                    }
                }
            }
            .tint(.themeHighlight)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold)).padding().background(Color.themeHighlight)
                            .foregroundColor(.white).clipShape(Circle()).shadow(radius: 5, x: 0, y: 2)
                    }.padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet, onDismiss: {
            if !newRecord.hospital.isEmpty && !newRecord.therapistName.isEmpty {
                records.append(newRecord)
            }
            newRecord = MedicalRecord()
        }) {
            AddOrEditRecordView(record: $newRecord, isAppointmentOnly: true)
        }
        // ✅ 2. 移除 .onAppear 和 .onChange 中的 updateWidgetData() 呼叫
        .onAppear(perform: setupSampleData)
    }
    
    private func deleteTodayRecord(at offsets: IndexSet) {
        let recordsToDelete = offsets.map { recordsForToday[$0] }
        records.removeAll { record in
            recordsToDelete.contains(where: { $0.id == record.id })
        }
    }
    
    private func deleteWeeklyRecord(at offsets: IndexSet) {
        let recordsToDelete = offsets.map { weeklyRecords[$0] }
        records.removeAll { record in
            recordsToDelete.contains(where: { $0.id == record.id })
        }
    }
    
    private func setupSampleData() {
        guard records.isEmpty else { return }
        let calendar = Calendar.current
        let today = Date()
        
        if let todayAt10AM = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today),
           let tomorrow = calendar.date(byAdding: .day, value: 1, to: today),
           let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) {
            
            records.append(MedicalRecord(hospital: "康復診所", therapistName: "林醫師", appointmentTime: todayAt10AM, affectedPart: "肩頸", treatmentContent: "熱敷與電療", doctorsOrders: "避免提重物。"))
            records.append(MedicalRecord(hospital: "復興診所", therapistName: "王醫師", appointmentTime: tomorrow, affectedPart: "右手腕"))
            records.append(MedicalRecord(hospital: "中山物理治療所", therapistName: "李治療師", appointmentTime: nextWeek, affectedPart: "腰部"))
        }
    }
    
    // ✅ 3. 將整個 updateWidgetData() 函式完全移除
    /*
    private func updateWidgetData() {
        // ... (所有相關程式碼都已刪除)
    }
    */
}
