import SwiftData
import SwiftUI

struct TimerView: View
{
    @Environment(\.modelContext) private var modelContext
    let topicID: UUID
    let topicName: String

    @State private var timer = StudySessionTimer()
    
    // Study if this properties have to be @States
    @State private var currentSession: StudySession?
    @State private var currentInterval: SessionInterval?

    private var currentElapsed: TimeInterval
    {
        TimeInterval(timer.secondsElapsed)
    }

    private var isRunning: Bool
    {
        timer.isRunning
    }

    private var primaryButtonTitle: String
    {
        if currentSession == nil
        {
            return "Start"
        }

        return isRunning ? "Pause" : "Resume"
    }

    var body: some View
    {
        VStack(spacing: 20)
        {
            TimerTopicCard(topicName: topicName)
            
            Spacer()
            
            Text(formattedTime(currentElapsed))
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            Spacer()
            
            HStack(spacing: 24)
            {
                Button
                {
                    performPrimaryTimerAction()
                }
                label:
                {
                    timerActionButtonLabel(
                        title: primaryButtonTitle,
                        isEnabled: true,
                        isPrimary: true
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button
                {
                    do
                    {
                        try stopSession()
                    }
                    catch
                    {}
                }
                label:
                {
                    timerActionButtonLabel(
                        title: "Stop",
                        isEnabled: currentSession != nil,
                        isPrimary: false
                    )
                }
                .buttonStyle(.plain)
                .disabled(currentSession == nil)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Timer")
        .onAppear
        {
            do
            {
                try startSession()
            }
            catch
            {}
        }
        .onDisappear
        {
            do
            {
                try stopSession()
            }
            catch
            {}
        }
    }

    private func timerActionButtonLabel(title: String, isEnabled: Bool, isPrimary: Bool) -> some View
    {
        Circle()
            .fill(timerActionButtonFill(isEnabled: isEnabled, isPrimary: isPrimary))
            .frame(width: 96, height: 96)
            .shadow(
                color: isEnabled ? Color("GoalPurple").opacity(0.28) : .clear,
                radius: 16,
                x: 0,
                y: 8
            )
            .overlay
            {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isEnabled ? Color.white : Color.secondary)
            }
    }

    private func timerActionButtonFill(isEnabled: Bool, isPrimary: Bool) -> AnyShapeStyle
    {
        guard isEnabled else
        {
            return AnyShapeStyle(Color(.secondarySystemFill))
        }

        if isPrimary
        {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color("GoalLightPurple"), Color("GoalPurple")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        else
        {
            return AnyShapeStyle(Color.accentColor)
        }
    }

    private func startSession() throws
    {
        guard timer.isRunning == false,
               currentSession == nil,
                currentInterval == nil
        else
        {
            return
        }

        let now = Date.now

        let session = StudySession(
            topicID: topicID,
            startDate: now
        )

        let interval = SessionInterval(
            startDate: now,
            studySession: session
        )

        session.sessionIntervals.append(interval)

        modelContext.insert(session)

        currentSession = session
        currentInterval = interval

        try modelContext.save()

        timer.start()
    }
    
    private func stopSession() throws
    {
        guard currentSession != nil
        else
        {
            return
        }
    
        let now = Date.now

        currentSession?.endDate = now
        
        if currentInterval?.endDate == nil
        {
            currentInterval?.endDate = now
        }

        try modelContext.save()
        //deleteSessionIDFromUserDefaults()

        currentSession = nil
        currentInterval = nil
        
        timer.reset()
    }

    private func resumeSession() throws
    {
        guard timer.isRunning == false,
                currentSession != nil
        else
        {
            return
        }

        let now = Date.now

        let interval = SessionInterval(
            startDate: now,
            studySession: currentSession
        )
        
        currentSession?.sessionIntervals.append(interval)
        currentInterval = interval
        
        timer.start()
    }
    
    private func pauseSession() throws
    {
        guard timer.isRunning == true
        else
        {
            return
        }

        let now = Date.now
        
        currentInterval?.endDate = now
        
        try modelContext.save()
        timer.stop()
        
        currentInterval = nil
    }

    private func performPrimaryTimerAction()
    {
        do
        {
            if currentSession == nil
            {
                try startSession()
            }
            else if isRunning
            {
                try pauseSession()
            }
            else
            {
                try resumeSession()
            }
        }
        catch
        {}
    }

    private func formattedTime(_ seconds: TimeInterval) -> String
    {
        let value = max(Int(seconds), 0)
        let hours = value / 3_600
        let minutes = (value % 3_600) / 60
        let remainingSeconds = value % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
}

#Preview
{
    NavigationStack
    {
        TimerView(topicID: UUID(), topicName: "Mathematics")
    }
    .modelContainer(for: [StudySession.self], inMemory: true)
}
