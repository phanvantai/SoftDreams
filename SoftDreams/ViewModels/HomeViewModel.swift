import Foundation

class HomeViewModel: ObservableObject {
  @Published var profile: UserProfile?
  @Published var stories: [Story] = []
  @Published var error: AppError?
  
  // Dependencies
  private let userProfileService: UserProfileServiceProtocol
  private let storyService: StoryServiceProtocol
  private let autoUpdateService: AutoProfileUpdateService
  private let storyTimeNotificationService: StoryTimeNotificationServiceProtocol
  
  init(
    userProfileService: UserProfileServiceProtocol? = nil,
    storyService: StoryServiceProtocol? = nil,
    storyTimeNotificationService: StoryTimeNotificationServiceProtocol? = nil
  ) {
    self.userProfileService = userProfileService ?? ServiceFactory.shared.createUserProfileService()
    self.storyService = storyService ?? ServiceFactory.shared.createStoryService()
    self.storyTimeNotificationService = storyTimeNotificationService ?? ServiceFactory.shared.createStoryTimeNotificationService()
    self.autoUpdateService = AutoProfileUpdateService(userProfileService: userProfileService)
    
    // Don't automatically refresh in init to avoid race conditions
    // Let AppView handle the initial data loading flow
  }
  
  func refresh() {
    Logger.info("Refreshing home view data", category: .userProfile)
    do {
      profile = try userProfileService.loadProfile()
      stories = try storyService.loadStories()
      error = nil
      
      // Log current app state
      Logger.info("Home refresh completed - Stories count: \(stories.count)", category: .userProfile)
      
      // Only check for auto-updates if we have a profile
      if profile != nil {
        Task {
          await checkAndPerformAutoUpdates()
        }
      }
      
      // Check and schedule story time notifications if needed
      if let currentProfile = profile {
        Task {
          await ensureStoryTimeNotificationsScheduled(for: currentProfile)
        }
      }
      
    } catch {
      Logger.error("Failed to refresh home data: \(error.localizedDescription)", category: .userProfile)
      self.error = error as? AppError ?? .dataCorruption
    }
  }
  
  // MARK: - Convenience Properties
  var hasCompletedOnboarding: Bool {
    return (try? userProfileService.loadProfile()) != nil
  }
  
  var totalStoriesCount: Int {
    return (try? storyService.loadStories().count) ?? 0
  }
  
  func getStoriesCreatedToday() -> [Story] {
    do {
      let allStories = try storyService.loadStories()
      let calendar = Calendar.current
      let today = Date()
      
      return allStories.filter { story in
        calendar.isDate(story.date, inSameDayAs: today)
      }
    } catch {
      self.error = error as? AppError ?? .dataCorruption
      return []
    }
  }
  
  // MARK: - Auto-Update Methods
  
  /// Checks and performs automatic profile updates
  @MainActor
  private func checkAndPerformAutoUpdates() async {
    // Ensure we have a profile before attempting auto-updates
    guard let currentProfile = profile else {
      Logger.debug("No profile available - skipping auto-updates", category: .autoUpdate)
      return
    }
    
    guard autoUpdateService.needsAutoUpdate(profile: currentProfile) else {
      Logger.debug("No auto-updates needed", category: .autoUpdate)
      // Still check for due date notifications even if no profile updates needed
      await ensureDueDateNotificationsSetup()
      return
    }
    
    Logger.info("Performing automatic profile updates", category: .autoUpdate)
    let result = await autoUpdateService.performAutoUpdate(profile: currentProfile)
    
    if result.isSuccess && result.hasUpdates {
      // Refresh profile with updates
      do {
        profile = try userProfileService.loadProfile()
        
        Logger.info("Auto-update completed successfully", category: .autoUpdate)
      } catch {
        Logger.error("Failed to reload profile after auto-update: \(error.localizedDescription)", category: .autoUpdate)
        self.error = error as? AppError ?? .dataCorruption
      }
    } else if let error = result.error {
      Logger.error("Auto-update failed: \(error.localizedDescription)", category: .autoUpdate)
      // Don't show error to user for auto-updates, just log it
    }
    
    // Ensure due date notifications are properly set up
    await ensureDueDateNotificationsSetup()
  }
  
  /// Ensures story time notifications are set up for the current profile
  private func ensureStoryTimeNotificationsScheduled(for profile: UserProfile) async {
    Logger.debug("Checking if story time notifications are scheduled for \(profile.name)", category: .notification)
    
    // Check if notifications are already scheduled
    let hasScheduled = await storyTimeNotificationService.hasScheduledStoryTimeReminders()
    
    if !hasScheduled {
      Logger.info("No story time notifications found, attempting to schedule for \(profile.name)", category: .notification)
      
      // Schedule story time notifications
      let success = await storyTimeNotificationService.scheduleStoryTimeReminder(
        for: profile.storyTime,
        babyName: profile.displayName
      )
      
      if success {
        Logger.info("Successfully scheduled story time notifications for \(profile.displayName) at \(profile.storyTime.formatted(date: .omitted, time: .shortened))", category: .notification)
      } else {
        Logger.info("Failed to schedule story time notifications - likely due to permission not granted", category: .notification)
      }
    } else {
      Logger.debug("Story time notifications already scheduled for \(profile.name)", category: .notification)
    }
  }
  
  /// Ensures due date notifications are set up for pregnancy profiles
  private func ensureDueDateNotificationsSetup() async {
    guard let currentProfile = profile, currentProfile.isPregnancy else {
      return
    }
    
    Logger.debug("Ensuring due date notifications are set up for pregnancy profile", category: .notification)
    let notificationService = ServiceFactory.shared.createDueDateNotificationService()
    await notificationService.scheduleNotificationsForCurrentProfile()
  }
  
  /// Manually triggers auto-update check (for testing or manual refresh)
  func triggerAutoUpdate() {
    Task {
      await checkAndPerformAutoUpdates()
    }
  }
}
