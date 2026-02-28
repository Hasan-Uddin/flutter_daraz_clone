# DarazClone - Flutter App

A Daraz-style product listing built with **MVVM + SOLID** principles.  
The core challenge of this task is **scroll architecture** and api.
---
[**Live Demo**](https://hasan-uddin.github.io/flutter_daraz_clone/)
---

## Run Instructions

```bash
flutter pub get
flutter run
```

> **Demo credentials:** `johnd` / `m38rmF$`

## Packages Used
  - cupertino_icons
  - provider
  - cached_network_image
  - http


---

## Project Structure

```
lib/
├── main.dart                       # App entry + dependency injection
│
├── models/
│   ├── product.dart                # Product data class (pure data, no logic)
│   └── user.dart                   # User data class  (pure data, no logic)
│
├── services/
│   └── api_service.dart            # All HTTP calls — FakeStore API
│
├── viewmodels/
│   ├── auth_viewmodel.dart         # Login / logout state
│   └── product_viewmodel.dart      # Products + active tab state
│
├── views/
│   ├── login_screen.dart
│   ├── home_screen.dart            # ← Core scroll architecture lives here
│   └── profile_screen.dart
│
└── widgets/
    ├── product_card.dart           # One product row (stateless)
    └── sticky_tab_bar.dart         # The pinned tab bar widget
```

---

## Scroll Architecture

> **Rule: There is exactly ONE vertical scrollable in the entire screen.**

This is solved with a single `CustomScrollView` and three slivers:

```
┌──────────────────────────────────┐
│  SliverAppBar                    │  <- collapses when you scroll up
├──────────────────────────────────┤
│  SliverPersistentHeader(pinned)  │  <- tab bar sticks here permanently
├──────────────────────────────────┤
│  SliverList                      │  <- product cards (grows downward)
└──────────────────────────────────┘
```

When you switch tabs, **only the data inside `SliverList` changes**.  
The `ScrollController` is never replaced → scroll position is preserved → no jump.

---

## Question 1: How is horizontal swipe implemented?

A `GestureDetector` wraps the whole screen:

```dart
GestureDetector(
  behavior: HitTestBehavior.translucent,  // don't block vertical scroll
  onHorizontalDragEnd: (details) {
    if (velocity < -300) switchTab(current + 1);  // swipe left  → next tab
    if (velocity >  300) switchTab(current - 1);  // swipe right → prev tab
  },
)
```

**Why not `PageView`?**  
`PageView` is a second vertical/horizontal scrollable. On diagonal finger movements it competes with the outer `CustomScrollView` and causes jitter.  
Our `GestureDetector` only responds to *horizontal intent* and leaves vertical scrolling completely untouched.

---

## Question 2: Who owns the vertical scroll, and why?

**The `CustomScrollView` in `HomeScreen` — via a single `ScrollController`.**

There is one controller, created once, never replaced.  
Switching tabs only swaps the list of products fed to `SliverList`.  
The controller stays alive → position stays alive.

Pull-to-refresh also only re-fetches data. It never touches the controller.  
So pull-to-refresh works from any tab without resetting the scroll position.

---

## Question 3: Trade-offs / Limitations

| Trade-off | Explanation |
|---|---|
| **Shared scroll position across tabs** | All tabs share one scroll position. Independent per-tab positions would require `NestedScrollView`, which reintroduces scroll conflicts. Shared position is also how the real Daraz app behaves. |
| **No slide animation when switching tabs** | A sliding transition would need a `PageView`, which conflicts with the single-scroll architecture. Content swaps instantly instead. |
| **User ID hardcoded to 1** | FakeStore's login token doesn't include a user ID. the app always fetch user #1, which matches the demo credentials. A real app would decode the JWT. |

---

## SOLID Principles

| Principle | Where it's applied |
|---|---|
| **S — Single Responsibility** | `ApiService` only does HTTP. `AuthViewModel` only manages auth. `ProductViewModel` only manages products and tab state. Each file has one reason to change. |
| **O — Open / Closed** | To add a new tab, add one entry to `tabs` and `categories` in `ProductViewModel`. No other file needs to change. |
| **D — Dependency Inversion** | ViewModels receive `ApiService` via constructor — they don't create it. `main.dart` wires everything together. Swapping the API only requires changing one file. |

## Screenshots

<img width="439" height="644" alt="image" src="https://github.com/user-attachments/assets/2bf1c3c7-4d55-4af6-8949-5fb212752c75" />
<img width="407" height="635" alt="image" src="https://github.com/user-attachments/assets/ac638c8e-7fa0-407b-84f0-1d82a690c96d" />
<img width="371" height="642" alt="image" src="https://github.com/user-attachments/assets/93cf0b46-b8bb-4c35-8b31-a9ebdd4f9835" />
<img width="345" height="637" alt="image" src="https://github.com/user-attachments/assets/33201313-ac6c-4bdb-b82c-a924bc088ea6" />