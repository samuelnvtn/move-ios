# MOVE

<p align="center">
  <strong>Visit new places. Earn points. Move your body.</strong>
</p>

**MOVE** is a native iOS application that acts as your personal travel assistant and gamified explorer. Simply select interesting places on the map, and the integrated AI takes care of the rest—from proposing a logical route and estimating time to providing transit instructions. 

To make exploring more fun, each location features unique, AI-generated interactive tasks. By completing them, users earn experience points (XP), unlock themed badges, and track their daily activity.

## Screenshots

<p align="center">
  <img src="dashboard.png" width="250" alt="Dashboard">
  <img src="map.png" width="250" alt="Interactive Map">
  <img src="planner-prompt.png" width="250" alt="AI Planner Prompt">
</p>

<p align="center">
  <img src="itinerary.png" width="250" alt="Generated Itinerary">
  <img src="tasks.png" width="250" alt="AI Generated Tasks">
  <img src="stats.png" width="250" alt="User Stats and Badges">
</p>

## Key Features

* **Interactive Map:** Discover nearby places (museums, cafes, hotels, nature) and add them to your personalized trips.
* * **AI-Generated Tasks:** Engage with your surroundings by completing specific, location-based tasks (e.g., finding specific exhibits or art) to earn XP.
* **AI Planner:** Input a custom prompt and let AI generate detailed itineraries including public transport routes, walking times, and cost estimates.
* **Gamification & Stats:** Level up your profile, unlock badges (Landmark, Restaurant, Hotel, Nature, Museum), and monitor your 30-day activity charts.

## Tech Stack & Architecture

* **Platform:** Native iOS (Swift)
* **UI Framework:** SwiftUI
* **Architecture:** MVVM (Model-View-ViewModel) for clean separation of concerns and testability.
* **Local Storage:** CoreData
* **Map Integration:** Apple Maps
* **API Integration:** Google Places API, Google Gemini API
