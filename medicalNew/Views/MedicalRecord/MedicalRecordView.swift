import SwiftUI

// Define CalendarScope at the top level to avoid scope issues
enum CalendarScope {
    case month
    case week
}

// Extension for zerothHour
extension Date {
    var zerothHour: Date? {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
    }
}

// MedicalRecordHistoryView (unchanged)
struct MedicalRecordHistoryView: View {
    var records: [MedicalRecord]
    var body: some View {
        List(records) { record in
            VStack(alignment: .leading) {
                Text(record.hospital).font(.headline)
                Text("患部: \(record.affectedPart)").font(.subheadline).foregroundColor(.secondary)
            }
        }
        .navigationTitle("歷史紀錄")
    }
}

// CalendarView (corrected and consolidated)
struct CalendarView: View {
    @Binding var date: Date
    @Binding var scope: CalendarScope
    let appointments: [Appointment]
    
    private var appointmentDates: Set<DateComponents> {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.year, .month, .day]
        return Set(appointments.map { calendar.dateComponents(components, from: $0.appointmentTime) })
    }
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        VStack {
            // Navigation buttons with debug print
            HStack {
                Button(action: {
                    changeDate(by: -1)
                    print("Navigating to previous \(scope == .month ? "month" : "week"): \(date)")
                }) { Image(systemName: "chevron.left") }
                Spacer()
                Text(headerString(from: date)).font(.headline)
                Spacer()
                Button(action: {
                    changeDate(by: 1)
                    print("Navigating to next \(scope == .month ? "month" : "week"): \(date)")
                }) { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)

            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday).frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)

            if scope == .month {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(generateMonthDates(for: date), id: \.self) { date in
                        dayView(for: date)
                    }
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(generateWeekDates(for: date), id: \.self) { date in
                        dayView(for: date).frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.vertical)
    }

    @ViewBuilder
    private func dayView(for date: Date) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isCurrentMonth = calendar.isDate(date, equalTo: self.date, toGranularity: .month)
        let hasAppointment = hasAppointment(on: date)
        
        VStack(spacing: 4) {
            Text("\(day)")
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(calendar.isDateInToday(date) ? Color.blue.opacity(0.8) : Color.clear)
                .clipShape(Circle())
                .foregroundColor(calendar.isDateInToday(date) ? .white : (isCurrentMonth ? .primary : .secondary))
            
            if hasAppointment {
                Circle().fill(Color.red).frame(width: 5, height: 5)
            } else {
                Circle().fill(Color.clear).frame(width: 5, height: 5)
            }
        }
    }
    
    // Helper Functions
    private func hasAppointment(on date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return appointmentDates.contains(components)
    }
    
    private func headerString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = (scope == .month) ? "yyyy年 M月" : "yyyy年 M月 d日"
        return formatter.string(from: date)
    }

    private func changeDate(by value: Int) {
        let calendar = Calendar.current
        let component: Calendar.Component = (scope == .month) ? .month : .weekOfYear
        if let newDate = calendar.date(byAdding: component, value: value, to: date) {
            if scope == .month {
                if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: newDate)) {
                    self.date = firstDayOfMonth
                }
            } else {
                self.date = newDate
            }
            print("Date updated to: \(date)") // Debug print to confirm update
        }
    }

    private func generateMonthDates(for month: Date) -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstDayOfMonth = monthInterval.start.zerothHour else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        guard let gridStartDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: firstDayOfMonth) else { return [] }
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let totalDays = (daysInMonth + firstWeekday - 1 + 6) / 7 * 7
        var dates: [Date] = []
        
        for i in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: i, to: gridStartDate) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func generateWeekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        var dates: [Date] = []
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                dates.append(day)
            }
        }
        return dates
    }
}

// MedicalRecordView (corrected)
struct MedicalRecordView: View {
    @State private var appointments: [Appointment] = []
    @State private var medicalRecords: [MedicalRecord] = []
    @State private var showingAddSheet = false
    @State private var calendarScope: CalendarScope = .month
    @State private var selectedDate: Date = Date()
    @State private var refreshId = UUID() // Added to force refresh

    private var weeklyAppointments: [Appointment] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let oneWeekLater = calendar.date(byAdding: .day, value: 7, to: today) else { return [] }
        return appointments.filter {
            $0.appointmentTime >= today && $0.appointmentTime < oneWeekLater
        }.sorted { $0.appointmentTime < $1.appointmentTime }
    }
    
    private var calendarIdentifier: String {
        let formatter = DateFormatter()
        let format = (calendarScope == .month) ? "yyyy-MM" : "yyyy-ww"
        formatter.dateFormat = format
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Section {
                        Picker("日曆範圍", selection: $calendarScope) {
                            Text("月").tag(CalendarScope.month)
                            Text("週").tag(CalendarScope.week)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 5)
                        
                        CalendarView(date: $selectedDate, scope: $calendarScope, appointments: appointments)
                            .id(refreshId) // Use refreshId to force re-render
                    }
                    
                    Section(header: Text("一週內的醫療行程")) {
                        if weeklyAppointments.isEmpty {
                            Text("未來一週沒有預約").foregroundColor(.gray)
                        } else {
                            ForEach(weeklyAppointments) { appointment in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(appointment.clinicName).font(.headline)
                                    HStack { Image(systemName: "person.fill"); Text(appointment.therapistName) }.font(.subheadline)
                                    HStack { Image(systemName: "clock.fill"); Text(appointment.appointmentTime, style: .date); Text(appointment.appointmentTime, style: .time) }.font(.subheadline)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: MedicalRecordHistoryView(records: medicalRecords)) {
                            Label("查看歷史紀錄", systemImage: "book.fill")
                        }
                    }
                }
                .navigationTitle("行事曆")
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) { Text("新增醫療紀錄頁面") }
        .onAppear { setupSampleData() }
        .onChange(of: selectedDate) { _ in
            refreshId = UUID() // Force refresh when selectedDate changes
        }
    }
    
    private func setupSampleData() {
        if medicalRecords.isEmpty {
            medicalRecords.append(MedicalRecord(hospital: "台大醫院", therapistName: "陳治療師", affectedPart: "左膝", treatmentContent: "物理治療", doctorsOrders: "每日熱敷"))
        }
        if appointments.isEmpty {
            let today = Date()
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
            let twoWeeksLater = Calendar.current.date(byAdding: .day, value: 14, to: today)!
            appointments.append(Appointment(clinicName: "復興診所", therapistName: "王醫師", appointmentTime: tomorrow))
            appointments.append(Appointment(clinicName: "中山物理治療所", therapistName: "李治療師", appointmentTime: nextWeek))
            appointments.append(Appointment(clinicName: "未來醫院", therapistName: "高醫師", appointmentTime: twoWeeksLater))
        }
    }
}

// Preview
#if DEBUG
struct MedicalRecordView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalRecordView()
    }
}
#endif

struct CalendarWrapper: View {
    @State var date: Date = .now
    
    var body: some View {
        CalendarView(
            date: $date,
            scope: .constant(.month),
            appointments: []
        )
    }
}

#Preview {
    CalendarWrapper()
}
