
# Scroll2Grow 🌱
### Don't Just Stop Scrolling. Start Growing.

Scroll2Grow is a gamified mobile application designed to encourage users to reduce unproductive scrolling and develop healthier digital habits. It helps users become more aware of their scrolling habits and encourages them to replace excessive scrolling with meaningful activities.

The application combines a simulated scrolling feed, mindful break reminders, mood-based activity recommendations, XP rewards, and daily streaks to make productive behaviour more engaging.

## 🎯 Objectives

- Encourage users to become more aware of their scrolling habits.
- Promote mindful breaks during prolonged in-app scrolling.
- Recommend meaningful activities based on mood and context.
- Motivate users through experience points (XP) and daily streaks.
- Track activity completion and personal progress.
- Encourage healthier digital habits through positive reinforcement.

## ✨ Features

### 1. User Authentication
- User registration and login using Firebase Authentication.
- Personalised user profiles.
- Access to application features after authentication.

### 2. Home Dashboard
- Displays a personalised greeting.
- Shows accumulated XP points and level progress.
- Displays daily streak information.
- Provides quick access to the scrolling feed and settings.

### 3. Smart Scroll Feed
- Displays sample posts retrieved from the DummyJSON API.
- Tracks the duration of an active in-app scrolling session.
- Displays a mindful-break reminder after a predefined time threshold.
- Allows users to continue scrolling or choose to take a break.

### 4. Mood Selection
Users can select their current mood before receiving an activity recommendation.

Available mood options include:
- Bored
- Stressed
- Tired
- Motivated

### 5. Context-Aware Activity Recommendations
- Suggests activities based on the selected mood and available contextual information.
- Considers factors such as scrolling duration and time of day.
- Displays an activity description and estimated completion time.
- Allows users to proceed with an activity or return to the feed.

### 6. Activity Completion and XP Rewards
- Allows users to mark recommended activities as completed.
- Awards XP based on the configured activity-duration rule.
- Displays a reward confirmation after completion.
- Stores activity completion records in Cloud Firestore.
- Includes duplicate-prevention logic for recorded completions.

### 7. Daily Streaks and Progress Tracking
- Tracks consecutive days with qualifying activity completions.
- Maintains the current and longest streak.
- Updates XP and streak information in the user's profile.
- Displays progress on the Home dashboard.

### 8. Notification Settings
- Allows users to enable or disable reminders.
- Supports configurable reminder intervals, such as hourly or daily.
- Stores notification preferences locally.
- Provides reminders with the message: "Ready to focus? Start Now."

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile development |
| Dart | Application programming language |
| Riverpod | State management |
| MVVM | Application architecture |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database and progress storage |
| DummyJSON API | Sample scrolling feed data |
| flutter_local_notifications | Local notifications |
| SharedPreferences | Local preference storage |

## 🏗️ Architecture

The application follows the Model–View–ViewModel (MVVM) architecture.

- **Model:** Represents application data, such as feed posts, activities, and user progress.
- **View:** Displays the user interface and handles user interactions.
- **ViewModel:** Manages UI state and application logic.
- **Services:** Handle Firebase operations, feed data retrieval, recommendations, activity completion, and notifications.

This structure separates responsibilities and makes the application easier to maintain and extend.

## 🔄 Application Workflow

1. The user logs in or creates an account.
2. The Home dashboard displays the user's current progress.
3. The user opens the Smart Scroll feed.
4. The session timer tracks active in-app scrolling.
5. A reminder appears when the configured threshold is reached.
6. The user chooses to continue scrolling or take a break.
7. If taking a break, the user selects their current mood.
8. The application recommends a suitable activity.
9. The user completes the activity and receives XP.
10. The application updates the user's progress and streak information.

## ⚙️ Prerequisites

Before running the project, install the following:

- Flutter SDK
- Dart SDK compatible with your Flutter version
- Android Studio or Visual Studio Code
- Android SDK and an emulator or physical Android device
- A Firebase project

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd scrool2grow
```

Replace `<YOUR_REPOSITORY_URL>` with your Git repository URL.

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a project in the Firebase Console.
2. Register your Android application using its application ID.
3. Configure Firebase Authentication and enable the required sign-in method.
4. Create a Cloud Firestore database.
5. Configure Firebase for Flutter using FlutterFire CLI if needed.
6. Ensure `firebase_options.dart` is generated and correctly configured.

The application should initialise Firebase before accessing authentication or Firestore services.

### 4. Configure Android Permissions

Ensure the Android manifest contains the permissions required by the implemented features, including internet access and notification permissions where applicable.

For example, internet access is declared in:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Notification permissions and Android notification configuration should match the project's installed plugin version and implementation.

### 5. Run the Application

Connect an Android device or start an emulator, then run:

```bash
flutter run
```

### 6. Build an APK

To generate a release APK:

```bash
flutter build apk --release
```

The APK is normally generated at:

`build/app/outputs/flutter-apk/app-release.apk`

## 🗄️ Firestore Data Structure

The application stores user information and activity completion records in Cloud Firestore.

Example structure:

```text
users/
  {uid}/
    currentXp
    streakDays
    longestStreak
    lastActivityDate

    activity_completions/
      {sessionId_activityId}/
        activityTitle
        mood
        xp
        durationMinutes
        completedAt
        sessionId
        activityDate
```

The exact fields and document structure should match the current implementation.

Firestore security rules should ensure that authenticated users can access only the data they are authorised to read or modify.

## 🔔 Notifications

Scroll2Grow uses local notifications to remind users to refocus on meaningful activities.

Example notification:

- **Title:** Scroll2Grow
- **Message:** Ready to focus? Start Now.

Users can configure reminder preferences through the Notification Settings page.

Notification delivery depends on device permissions, operating-system restrictions, and the Android notification configuration.

## 🔬 Project Background

Scroll2Grow was developed as part of a research project exploring young adults' perceptions of static and context-aware gamification strategies for addressing doomscrolling.

The research compared two gamification concepts through a survey of 65 participants aged 18–30. The results showed similar mean perception scores for static and context-aware designs.

- Static gamification: Mean = 3.21
- Context-aware gamification: Mean = 3.27
- Paired t-test: p = .341

The difference was not statistically significant. Therefore, the findings do not establish that context-aware gamification is more effective than static gamification.

The application translates ideas from the research into a working prototype. Its real-world effectiveness in reducing scrolling behaviour requires further user testing.

## 🔮 Future Enhancements

- Integration with supported device screen-time APIs.
- Improved personalisation using user preferences and activity history.
- Additional activity categories and custom activities.
- Detailed progress analytics and activity history.
- Evaluation of the application through longer-term user studies.
- Further testing of the effect of rewards and reminders on user engagement.

## 🔐 Privacy and Security

- Firebase Authentication manages user sign-in.
- Cloud Firestore stores user profiles and activity records.
- SharedPreferences stores local notification preferences.
- The current feed uses sample posts from DummyJSON.
- Access to user data should be controlled through appropriate Firestore security rules.

The current prototype tracks scrolling inside its own feed and does not automatically monitor activity across other social media applications.

## 👨‍💻 Contributors

- Anand Pal
- Soham Naik

## 📄 License

A license has not yet been specified for this project. Add an appropriate license before distributing the source code publicly.

---

**Scroll2Grow — Turn scrolling time into growing time.** 🌱
