# SoftDreams iOS App - Copilot Instructions

## Project Overview
SoftDreams is a SwiftUI iOS application that generates personalized bedtime stories for children. The app uses AI to create custom stories based on the child's profile, interests, and preferences.

## Technical Stack
- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Language**: Swift 5.0
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults
- **Target Devices**: iPhone and iPad
- **Testing Framework**: Swift Testing
- **Development Approach**: Fast Implementation with Optional Testing

## Key Features
1. **Onboarding Flow**: Multi-step setup for child profile and preferences
2. **Story Generation**: AI-powered custom story creation
3. **Library**: Save and manage favorite stories
4. **Settings**: Profile management and app preferences
5. **Customization**: Story length, theme, and character options

## Code Style Guidelines

### SwiftUI Best Practices
- Use `@StateObject` for view model initialization
- Use `@ObservedObject` when passing view models between views
- Prefer `NavigationStack` over deprecated `NavigationView`
- Use `.sheet()` for modal presentations
- Implement proper state management with `@State` and `@Published`

### Architecture Patterns
- Follow MVVM pattern consistently
- Keep views lightweight and delegate business logic to ViewModels
- Use `@Published` properties in ViewModels for reactive UI updates
- Implement proper separation of concerns

### Data Management
- Use `UserDefaultsManager` for all data persistence
- Implement proper Codable conformance for data models
- Handle async operations with proper `Task` and `await/async` patterns
- Use `MainActor.run` when updating UI from background threads

## File Naming Conventions
- Views: `[Feature]View.swift` (e.g., `HomeView.swift`)
- ViewModels: `[Feature]ViewModel.swift` (e.g., `HomeViewModel.swift`)
- Models: Descriptive names (e.g., `Story.swift`, `UserProfile.swift`)
- Organize files in logical folders by feature

### Component Organization Rules
- **Feature-specific components**: Components used only within a single feature should be placed in a `Components/` subfolder within that feature's view folder (e.g., `Views/Onboarding/Components/ProfileSummaryRow.swift`)
- **Reusable components**: Components that can be used across multiple features should be placed in `Views/Common/` folder (e.g., `Views/Common/ActionCard.swift`)

## Development Guidelines

### Fast Implementation Approach
**Focus on rapid feature development and iteration:**

1. **Feature First**: Implement core functionality quickly to validate concepts
2. **Iterative Improvement**: Refine and enhance features based on testing and feedback
3. **Pragmatic Testing**: Add tests for critical functionality when stability is needed

### Testing Standards (Optional)
- Add tests for core business logic when time permits
- Focus testing efforts on critical user flows
- Test data persistence and error handling for important features

### Test Naming Convention
- Test files: `[Feature/Component]Tests.swift`
- Test methods: Use descriptive names that explain the scenario
- Example: `testOnboardingViewModel_WhenValidProfileData_ShouldSaveSuccessfully()`

### Test Organization
- Place test files in `SoftDreamsTests/` folder when needed
- Mirror the main app folder structure
- Group related tests in the same file
- Use `@Test` attribute for Swift Testing framework
- **Place mocks for testing in `SoftDreamsTests/Mocks/` folder for consistency**

### When Adding New Features:
1. **Implement core functionality** quickly to validate the concept
2. Create appropriate models in `Models/` folder
3. Implement ViewModels with `@Published` properties
4. Create SwiftUI views following existing patterns
5. Update `UserDefaultsManager` if persistence is needed
6. Follow the established navigation patterns
7. Place feature-specific components in `Views/[Feature]/Components/` folder
8. Only add components to `Views/Common/` if they are truly reusable across multiple features
9. **Add tests later** for critical functionality when stability is required

### When Modifying Existing Code:
- Implement changes quickly and test manually
- Maintain consistency with existing code style
- Update related ViewModels when changing data models
- Ensure proper error handling for async operations
- Test onboarding flow after profile-related changes

### UI/UX Considerations:
- Maintain child-friendly design patterns
- Use appropriate button styles (`.borderedProminent`, `.bordered`)
- Implement proper accessibility features

## Common Patterns

### View Model Pattern:
```swift
class FeatureViewModel: ObservableObject {
    @Published var property: Type = defaultValue
    
    func performAction() {
        // Business logic here
    }
}
```

### Async Story Generation:
```swift
Task {
    await viewModel.generateStory(profile: profile, options: options)
    // Update UI state
}
```

### Navigation:
```swift
.navigationDestination(isPresented: $showView) {
    DestinationView(viewModel: viewModel)
}
```

## Testing Considerations
- Test onboarding flow completion when needed
- Verify story generation and saving functionality periodically
- Test data persistence across app launches for critical features
- **Focus on manual testing** during development for speed
- Add automated tests for core business logic when stability is needed
- Test error handling and edge cases for critical flows
- Use Swift Testing framework with `@Test` attributes when writing tests
- Mock external dependencies in unit tests

## Future Development Notes
- Story generation currently uses placeholder/mock implementation
- Progress tracking feature is marked as TODO
- Voice narration is planned but not implemented
- Image generation for stories is placeholder

## Bundle Identifier
`com.randomtech.SoftDreams`

## Development Team
K6GZTHQ9Z5

When working on this project, prioritize child safety, intuitive UI design, and maintainable code architecture following the established MVVM patterns.