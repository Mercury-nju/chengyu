import SwiftUI
import UserNotifications

struct DailyReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Preset reminders
    @State private var morningEnabled = true
    @State private var morningTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    @State private var afternoonEnabled = true
    @State private var afternoonTime = Calendar.current.date(from: DateComponents(hour: 14, minute: 0)) ?? Date()
    
    @State private var eveningEnabled = true
    @State private var eveningTime = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    
    // Custom reminders
    @State private var customReminders: [CustomReminder] = []
    @State private var showAddReminder = false
    @State private var showPermissionAlert = false
    
    struct CustomReminder: Identifiable {
        let id = UUID()
        var time: Date
        var isEnabled: Bool
        var label: String
    }
    
    var body: some View {
        ZStack {
            // Dark background to match app theme
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("每日提醒")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddReminder = true
                    }) {
                        Text("添加")
                            .font(.system(size: 16))
                            .foregroundColor(.cyan)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Morning Reminder
                        ReminderCard(
                            title: "晨间提醒",
                            time: $morningTime,
                            isEnabled: $morningEnabled,
                            weekdays: "工作日",
                            onToggle: { enabled in
                                if enabled {
                                    scheduleMorningReminder()
                                } else {
                                    cancelReminder(id: "morning")
                                }
                            }
                        )
                        
                        // Afternoon Reminder
                        ReminderCard(
                            title: "午后提醒",
                            time: $afternoonTime,
                            isEnabled: $afternoonEnabled,
                            weekdays: "每天",
                            onToggle: { enabled in
                                if enabled {
                                    scheduleAfternoonReminder()
                                } else {
                                    cancelReminder(id: "afternoon")
                                }
                            }
                        )
                        
                        // Evening Reminder
                        ReminderCard(
                            title: "傍晚提醒",
                            time: $eveningTime,
                            isEnabled: $eveningEnabled,
                            weekdays: "每天",
                            onToggle: { enabled in
                                if enabled {
                                    scheduleEveningReminder()
                                } else {
                                    cancelReminder(id: "evening")
                                }
                            }
                        )
                        
                        // Custom Reminders
                        ForEach($customReminders) { $reminder in
                            CustomReminderCard(
                                reminder: $reminder,
                                onDelete: {
                                    deleteCustomReminder(reminder)
                                },
                                onToggle: { enabled in
                                    if enabled {
                                        scheduleCustomReminder(reminder)
                                    } else {
                                        cancelReminder(id: reminder.id.uuidString)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("需要通知权限", isPresented: $showPermissionAlert) {
            Button("取消", role: .cancel) { }
            Button("去设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("请在设置中允许澄域发送通知，以便接收每日提醒")
        }
        .sheet(isPresented: $showAddReminder) {
            AddCustomReminderView { label, time in
                let newReminder = CustomReminder(time: time, isEnabled: true, label: label)
                customReminders.append(newReminder)
                scheduleCustomReminder(newReminder)
            }
        }
        .onAppear {
            loadReminderSettings()
            requestNotificationPermission()
        }
    }
    
    // Morning reminder messages
    let morningMessages = [
        "清晨微光，心绪归位。此刻，让光澄澈。",
        "深呼吸。今日启程，专注随行。",
        "新的开始，新的心流。与澄域同行。"
    ]
    
    // Afternoon/Evening messages
    let daytimeMessages = [
        "此刻，心流如何？开启片刻宁静。",
        "放下喧嚣，你的 SV 值在等你。",
        "闭眼一分钟。与光，同呼吸，回归内在。"
    ]
    
    // Custom reminder messages
    let customMessages = [
        "专注时刻已至。来澄域铸核。",
        "抵御分心。你的心流正在等你开启。"
    ]
    
    func scheduleMorningReminder() {
        let message = morningMessages.randomElement() ?? morningMessages[0]
        scheduleReminder(id: "morning", time: morningTime, message: message)
    }
    
    func scheduleAfternoonReminder() {
        let message = daytimeMessages.randomElement() ?? daytimeMessages[0]
        scheduleReminder(id: "afternoon", time: afternoonTime, message: message)
    }
    
    func scheduleEveningReminder() {
        let message = daytimeMessages.randomElement() ?? daytimeMessages[0]
        scheduleReminder(id: "evening", time: eveningTime, message: message)
    }
    
    func scheduleCustomReminder(_ reminder: CustomReminder) {
        let message = customMessages.randomElement() ?? customMessages[0]
        scheduleReminder(id: reminder.id.uuidString, time: reminder.time, message: message)
    }
    
    func scheduleReminder(id: String, time: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = L10n.appName
        content.body = message
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func deleteCustomReminder(_ reminder: CustomReminder) {
        cancelReminder(id: reminder.id.uuidString)
        customReminders.removeAll { $0.id == reminder.id }
        saveReminderSettings()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    func loadReminderSettings() {
        // Load preset reminders
        morningEnabled = UserDefaults.standard.bool(forKey: "morningEnabled")
        afternoonEnabled = UserDefaults.standard.bool(forKey: "afternoonEnabled")
        eveningEnabled = UserDefaults.standard.bool(forKey: "eveningEnabled")
        
        if let morningData = UserDefaults.standard.object(forKey: "morningTime") as? Date {
            morningTime = morningData
        }
        if let afternoonData = UserDefaults.standard.object(forKey: "afternoonTime") as? Date {
            afternoonTime = afternoonData
        }
        if let eveningData = UserDefaults.standard.object(forKey: "eveningTime") as? Date {
            eveningTime = eveningData
        }
        
        // Load custom reminders
        if let data = UserDefaults.standard.data(forKey: "customReminders"),
           let decoded = try? JSONDecoder().decode([CustomReminderData].self, from: data) {
            customReminders = decoded.map { data in
                CustomReminder(time: data.time, isEnabled: data.isEnabled, label: data.label)
            }
        }
    }
    
    func saveReminderSettings() {
        // Save preset reminders
        UserDefaults.standard.set(morningEnabled, forKey: "morningEnabled")
        UserDefaults.standard.set(afternoonEnabled, forKey: "afternoonEnabled")
        UserDefaults.standard.set(eveningEnabled, forKey: "eveningEnabled")
        
        UserDefaults.standard.set(morningTime, forKey: "morningTime")
        UserDefaults.standard.set(afternoonTime, forKey: "afternoonTime")
        UserDefaults.standard.set(eveningTime, forKey: "eveningTime")
        
        // Save custom reminders
        let customData = customReminders.map { reminder in
            CustomReminderData(time: reminder.time, isEnabled: reminder.isEnabled, label: reminder.label)
        }
        if let encoded = try? JSONEncoder().encode(customData) {
            UserDefaults.standard.set(encoded, forKey: "customReminders")
        }
    }
    
    struct CustomReminderData: Codable {
        let time: Date
        let isEnabled: Bool
        let label: String
    }
}

// MARK: - Reminder Card

struct ReminderCard: View {
    let title: String
    @Binding var time: Date
    @Binding var isEnabled: Bool
    let weekdays: String
    let onToggle: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(.cyan)
                    .onChange(of: isEnabled) { newValue in
                        onToggle(newValue)
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if isEnabled {
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack {
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .onChange(of: time) { _ in
                            onToggle(true) // Re-schedule with new time
                        }
                    
                    Spacer()
                    
                    Text(weekdays)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Custom Reminder Card

struct CustomReminderCard: View {
    @Binding var reminder: DailyReminderView.CustomReminder
    let onDelete: () -> Void
    let onToggle: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(reminder.label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $reminder.isEnabled)
                    .labelsHidden()
                    .tint(.cyan)
                    .onChange(of: reminder.isEnabled) { newValue in
                        onToggle(newValue)
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if reminder.isEnabled {
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack {
                    DatePicker("", selection: $reminder.time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .colorScheme(.dark)
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Text("删除")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}


// MARK: - Add Custom Reminder View

struct AddCustomReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var reminderLabel = ""
    @State private var reminderTime = Date()
    let onAdd: (String, Date) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Label Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("提醒标签")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("例如：专注提醒", text: $reminderLabel)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Time Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("提醒时间")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("添加提醒")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.done) {
                        let label = reminderLabel.isEmpty ? "自定义提醒" : reminderLabel
                        onAdd(label, reminderTime)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.cyan)
                    .disabled(reminderLabel.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
