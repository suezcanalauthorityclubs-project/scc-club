# Suez Canal Club (SCC) Membership System ⚓

A professional Flutter application designed to manage club memberships efficiently. The system handles member profiles, family dependents (wives and children), and membership statuses using a scalable cloud architecture.

---

## Application Logic & Architecture

The application is built following a **Clean Architecture** approach to ensure maintainability and performance.

### 1. Data Structure Logic (Firestore)
Instead of storing all family data in a single heavy document, we utilize **Sub-collections**. This optimizes read/write costs and enhances query performance.

* **Main Collection (`main_membership`):** Stores primary member details (Name, Job, National ID, Expiry Date).
* **Sub-collection (`wives`):** Nested within the member document to manage multiple spouses if applicable.
* **Sub-collection (`children`):** Nested within the member document for detailed tracking of dependents.



### 2. State Management (BLoC Pattern)
We use the **BLoC (Business Logic Component)** pattern to separate the UI from the data logic.
* **Events:** User actions like `FetchMemberDetails`.
* **States:** The UI reacts to states like `MemberLoading`, `MemberLoaded`, or `MemberError`.
* **Performance:** Integrated with **Equatable** to prevent unnecessary UI rebuilds, ensuring a smooth 60FPS experience.



---

## Tech Stack
* **Frontend:** Flutter (Material 3)
* **Backend:** Firebase Firestore
* **State Management:** flutter_bloc
* **Data Consistency:** Equatable
* **Version Control:** Git & GitHub

---

## Project Structure
```text
lib/
 ├── models/      # Data blueprints (Member, Child, Wife models)
 ├── logic/       # BLoC implementation (Events, States, Blocs)
 ├── services/    # Firebase Firestore API calls
 └── ui/          # Screens and reusable Widgets

                                    ---Meet The Team---
Team Leader
    Aya Abdullah

Business Wise & Documentation
    Aya Abdullah
    Mohamed Nagy
    Ahmed Gamal

UI/UX Design Team
    Mohammed Said
    Attia El-Saadi
    Mostafa Assem

Database & Logic Team
    Ahmed Badr
    Muhammad Hasan