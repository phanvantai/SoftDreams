//
//  MockServices.swift
//  SoftDreamsTests
//
//  Created by GitHub Copilot on 6/4/25.
//

@testable import SoftDreams
import Foundation
import StoreKit

// MARK: - Mock Story Generation Service

class MockStoryGenerationService: StoryGenerationServiceProtocol {
    var mockStory: Story?
    var shouldThrow = false
    var generateStoryCallCount = 0
    var generateDailyStoryCallCount = 0
    
    func generateStory(for profile: UserProfile, with options: StoryOptions) async throws -> Story {
        generateStoryCallCount += 1
        
        if shouldThrow {
            throw StoryGenerationError.generationFailed
        }
        
        return mockStory ?? Story.createMockStory()
    }
    
    func generateDailyStory(for profile: UserProfile) async throws -> Story {
        generateDailyStoryCallCount += 1
        
        if shouldThrow {
            throw StoryGenerationError.generationFailed
        }
        
        return mockStory ?? Story.createMockStory()
    }
    
    func canGenerateStory(for profile: UserProfile, with options: StoryOptions) -> Bool {
        return !shouldThrow
    }
    
    func getSuggestedThemes(for profile: UserProfile) -> [String] {
        return ["Adventure", "Fantasy", "Science Fiction"]
    }
}

// MARK: - Mock Story Service

class MockStoryService: StoryServiceProtocol {
    var mockStories: [Story] = []
    var saveStoryCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false
    var shouldThrowOnUpdate = false
    
    func saveStories(_ stories: [Story]) throws {
        for story in stories {
            try saveStory(story)
        }
    }
    
    func loadStories() throws -> [Story] {
        return mockStories
    }
    
    func saveStory(_ story: Story) throws {
        saveStoryCallCount += 1
        
        if shouldThrowOnSave {
            throw AppError.storySaveFailed
        }
        
        // Update existing story or add new one
        if let index = mockStories.firstIndex(where: { $0.id == story.id }) {
            mockStories[index] = story
        } else {
            mockStories.append(story)
        }
    }
    
    func deleteStory(withId id: String) throws {
        if shouldThrowOnDelete {
            throw AppError.dataCorruption
        }
        
        mockStories.removeAll { $0.id.uuidString == id }
    }
    
    func updateStory(_ story: Story) throws {
        if shouldThrowOnUpdate {
            throw AppError.dataCorruption
        }
        
        if let index = mockStories.firstIndex(where: { $0.id == story.id }) {
            mockStories[index] = story
        } else {
            throw AppError.invalidData
        }
    }
    
    func getStory(withId id: String) throws -> Story? {
        return mockStories.first { $0.id.uuidString == id }
    }
    
    func getStoryCount() throws -> Int {
        return mockStories.count
    }
}

// MARK: - Mock Story Generation Config Service

class MockStoryGenerationConfigService: StoryGenerationConfigServiceProtocol {
    var mockConfig: StoryGenerationConfig?
    var saveConfigCallCount = 0
    var loadConfigCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    
    func saveConfig(_ config: StoryGenerationConfig) throws {
        saveConfigCallCount += 1
        
        if shouldThrowOnSave {
            throw AppError.dataCorruption
        }
        
        mockConfig = config
    }
    
    func loadConfig() throws -> StoryGenerationConfig {
        loadConfigCallCount += 1
        
        if shouldThrowOnLoad {
            throw AppError.dataCorruption
        }
        
        return mockConfig ?? StoryGenerationConfig(
            subscriptionTier: .free,
            selectedModel: .gpt35Turbo,
            storiesGeneratedToday: 0,
            lastResetDate: Date()
        )
    }
    
    func resetConfig() throws {
        if shouldThrowOnSave {
            throw AppError.dataCorruption
        }
        mockConfig = nil
    }
    
    func configExists() -> Bool {
        return mockConfig != nil
    }
}

// MARK: - Helper Extensions

extension Story {
    static func createMockStory() -> Story {
        return Story(
            id: UUID(),
            title: "Test Story",
            content: "Once upon a time...",
            date: Date(),
            isFavorite: false,
            theme: "Adventure",
            length: .medium,
            characters: ["Hero"],
            ageRange: .preschooler,
            readingTime: 5,
            tags: ["test"]
        )
    }
}

// MARK: - Mock StoryGenerationConfigService Protocol

protocol StoryGenerationConfigServiceProtocol {
    func saveConfig(_ config: StoryGenerationConfig) throws
    func loadConfig() throws -> StoryGenerationConfig
    func resetConfig() throws
    func configExists() -> Bool
}

// MARK: - Mock StoreKit Service

@MainActor
class MockStoreKitService: ObservableObject {
    @Published var subscriptions: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var subscriptionGroupStatus: Product.SubscriptionInfo.RenewalState?
    
    var mockSubscriptions: [Product] = [] {
        didSet {
            subscriptions = mockSubscriptions
        }
    }
    
    var hasActivePremiumSubscription: Bool = false
    
    func loadProducts() async {
        subscriptions = mockSubscriptions
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        purchasedSubscriptions.append(product)
        hasActivePremiumSubscription = true
        return true
    }
    
    func restorePurchases() async throws {
        // Mock restore functionality
    }
    
    func getSubscriptionStatus() async -> SubscriptionStatus {
        if hasActivePremiumSubscription {
            return .active(subscriptions.first!)
        }
        return .none
    }
}
