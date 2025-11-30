import SwiftUI

// MARK: - SV Heatmap Chart

struct SVHeatmapChart: View {
    let data: [SVHeatmapData]
    
    var body: some View {
        GeometryReader { geometry in
            let cellWidth = (geometry.size.width - 40) / 24
            let cellHeight: CGFloat = 20
            
            VStack(alignment: .leading, spacing: 8) {
                // Hour labels
                HStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        if hour % 3 == 0 {
                            Text("\(hour)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: cellWidth * 3)
                        }
                    }
                }
                .padding(.leading, 40)
                
                // Heatmap grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(0..<7, id: \.self) { day in
                            HStack(spacing: 2) {
                                // Day label
                                Text(dayLabel(day))
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(width: 35, alignment: .leading)
                                
                                // Hour cells
                                ForEach(0..<24, id: \.self) { hour in
                                    let cellData = data.first { $0.day == day && $0.hour == hour }
                                    
                                    Rectangle()
                                        .fill(cellData?.color ?? Color.gray.opacity(0.2))
                                        .frame(width: cellWidth, height: cellHeight)
                                        .cornerRadius(2)
                                        .shadow(color: cellData?.color.opacity(0.5) ?? .clear, radius: 2)
                                }
                            }
                        }
                    }
                }
                .frame(height: 200)
                
                // Legend
                HStack(spacing: 16) {
                    LegendItem(color: .cyan, label: "高")
                    LegendItem(color: .purple, label: "中")
                    LegendItem(color: Color.red.opacity(0.6), label: "低")
                }
                .padding(.top, 8)
            }
        }
        .frame(height: 280)
    }
    
    private func dayLabel(_ day: Int) -> String {
        let days = ["今天", "昨天", "2天前", "3天前", "4天前", "5天前", "6天前"]
        return days[day]
    }
}

// MARK: - Focus Interruption Chart

struct FocusInterruptionChart: View {
    let data: FocusInterruptionData
    
    var body: some View {
        VStack(spacing: 16) {
            // Ring Chart
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                // Completed ring
                Circle()
                    .trim(from: 0, to: 1 - data.interruptionRate)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .cyan.opacity(0.5), radius: 10)
                
                // Interrupted ring
                Circle()
                    .trim(from: 1 - data.interruptionRate, to: 1)
                    .stroke(
                        LinearGradient(
                            colors: [.red.opacity(0.6), .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .red.opacity(0.5), radius: 10)
                
                // Center text
                VStack(spacing: 4) {
                    Text("\(Int(data.interruptionRate * 100))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("中断率")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                StatItem(value: "\(data.completedSessions)", label: L10n.completed, color: .cyan)
                StatItem(value: "\(data.interruptedSessions)", label: L10n.interrupted, color: .red.opacity(0.6))
                StatItem(value: "\(Int(data.avgInterruptionTime / 60))\(L10n.minutesUnit)", label: L10n.avgDuration, color: .orange)
            }
        }
    }
}

// MARK: - SV Recovery Curve Chart

struct SVRecoveryCurveChart: View {
    let data: [SVRecoveryData]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height: CGFloat = 200
            
            ZStack {
                // Grid lines
                ForEach(0..<5) { i in
                    let y = height * CGFloat(i) / 4
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
                
                // Recovery curves
                if !data.isEmpty {
                    ForEach(Array(data.prefix(5).enumerated()), id: \.element.id) { index, recovery in
                        RecoveryCurvePath(recovery: recovery, width: width, height: height)
                            .stroke(
                                LinearGradient(
                                    colors: [.red.opacity(0.6), .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .opacity(1.0 - Double(index) * 0.15)
                    }
                }
                
                // Average recovery time label
                if !data.isEmpty {
                    let avgMinutes = Int(data.map { $0.duration }.reduce(0, +) / Double(data.count) / 60)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("平均恢复: \(avgMinutes)分钟")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.cyan)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.cyan.opacity(0.2))
                                )
                        }
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

struct RecoveryCurvePath: Shape {
    let recovery: SVRecoveryData
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start point (drop)
        let startX: CGFloat = 0
        let startY = height * CGFloat(1 - recovery.dropValue / 100)
        
        // End point (recovery)
        let endX = width
        let endY = height * CGFloat(1 - recovery.recoveryValue / 100)
        
        // Control points for smooth curve
        let controlX1 = width * 0.3
        let controlY1 = startY
        let controlX2 = width * 0.7
        let controlY2 = endY
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.addCurve(
            to: CGPoint(x: endX, y: endY),
            control1: CGPoint(x: controlX1, y: controlY1),
            control2: CGPoint(x: controlX2, y: controlY2)
        )
        
        return path
    }
}

// MARK: - HDA Impact Chart

struct HDAImpactChart: View {
    let data: [HDAImpactData]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(data.prefix(5)) { impact in
                HStack(spacing: 12) {
                    // Category icon
                    ZStack {
                        Circle()
                            .fill(categoryColor(impact.appCategory).opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: categoryIcon(impact.appCategory))
                            .font(.system(size: 16))
                            .foregroundColor(categoryColor(impact.appCategory))
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(impact.appCategory)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("\(impact.impactCount)次影响 · 平均-\(String(format: "%.1f", impact.avgSVDrop))%")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Bar
                    GeometryReader { geo in
                        let maxCount = data.map { $0.impactCount }.max() ?? 1
                        let width = geo.size.width * CGFloat(impact.impactCount) / CGFloat(maxCount)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor(impact.appCategory), categoryColor(impact.appCategory).opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: width, height: 8)
                            .shadow(color: categoryColor(impact.appCategory).opacity(0.5), radius: 4)
                    }
                    .frame(width: 80, height: 8)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "社交媒体": return .blue
        case "娱乐": return .purple
        default: return .purple
        }
    }
    
    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "社交媒体": return "bubble.left.and.bubble.right.fill"
        case "娱乐": return "play.circle.fill"
        default: return "play.circle.fill"
        }
    }
}

// MARK: - Meditation Effect Chart

struct MeditationEffectChart: View {
    let data: [MeditationEffectData]
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary Stats
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(data.count)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    Text("冥想次数")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "+%.1f%%", averageImprovement))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Text("平均提升")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(totalMinutes))分")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    Text("累计时长")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.vertical, 12)
            
            // Recent Sessions List
            VStack(spacing: 8) {
                ForEach(Array(data.prefix(5).enumerated()), id: \.element.id) { index, effect in
                    HStack(spacing: 12) {
                        // Date
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dateLabel(effect.sessionDate))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            Text("\(Int(effect.duration / 60))分钟")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(width: 60, alignment: .leading)
                        
                        // Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                
                                // Progress
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: min(geo.size.width, geo.size.width * CGFloat(effect.improvement / maxImprovement)), height: 8)
                                    .shadow(color: .cyan.opacity(0.5), radius: 4)
                            }
                        }
                        .frame(height: 8)
                        
                        // Value
                        Text(String(format: "+%.1f%%", effect.improvement))
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.green)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var averageImprovement: Double {
        guard !data.isEmpty else { return 0 }
        return data.map { $0.improvement }.reduce(0, +) / Double(data.count)
    }
    
    private var totalMinutes: Double {
        return data.map { $0.duration }.reduce(0, +) / 60
    }
    
    private var maxImprovement: Double {
        return data.map { $0.improvement }.max() ?? 1
    }
    
    private func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Helper Views

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}
