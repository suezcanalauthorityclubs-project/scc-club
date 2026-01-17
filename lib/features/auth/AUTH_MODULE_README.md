# Authentication Module Documentation

## Overview

The authentication module has been migrated from Firebase Auth to a custom Firestore-based implementation with session management via SharedPreferences.

## Architecture

### Firestore Users Collection Structure

```
users (collection)
  ├── {userId} (document)
  │   ├── username (string)
  │   ├── password (string)
  │   ├── role (string) - "member", "child", "wife", "security", etc.
  │   └── membership_id (string, optional) - references main_membership collection
```

### Layers

#### 1. **Domain Layer** (`domain/`)

- **UserEntity**: Represents the user with fields: `id`, `username`, `role`, `membershipId`
- **AuthRepository**: Abstract repository defining auth operations
  - `login(username, password)`: Authenticate user
  - `logout()`: Clear session
  - `getCurrentUser()`: Retrieve current user from session
  - `register(userData)`: Register new user

#### 2. **Data Layer** (`data/`)

##### Models (`models/user_model.dart`)

- **UserModel**: Extends UserEntity, handles Firestore serialization
- `fromMap()`: Converts Firestore document to UserModel
- `toMap()`: Converts UserModel to Firestore document format

##### Data Sources (`datasources/`)

- **AuthRemoteDataSource**: Abstract interface
- **AuthRemoteDataSourceImpl**: Implementation using Firestore
  - Queries Firestore users collection
  - Compares passwords (basic validation)
  - Manages session via SessionManager

##### Repositories (`repositories/`)

- **AuthRepositoryImpl**: Implements AuthRepository
- Bridges between Cubit and remote data source

#### 3. **Presentation Layer** (`presentation/`)

##### States (`cubit/auth_state.dart`)

- `AuthInitial`: Initial state
- `AuthLoading`: During login/logout
- `AuthAuthenticated`: User logged in successfully
- `AuthSessionRestored`: Session recovered from SharedPreferences
- `AuthError`: Error occurred
- `AuthUnauthenticated`: User logged out

##### Cubit (`cubit/auth_cubit.dart`)

- `checkExistingSession()`: Called on app startup
- `login(username, password)`: User login
- `logout()`: User logout and session clear

### Session Management

#### SessionManager Service (`core/services/session_manager.dart`)

Handles persistence of user session in SharedPreferences:

- `saveUserSession(user)`: Persists user data locally
- `getSavedUserSession()`: Retrieves persisted user
- `clearUserSession()`: Removes all session data
- `hasUserSession()`: Check if session exists

**Stored Keys:**

- `user_id`: Unique user identifier
- `username`: User's username
- `role`: User's role
- `membership_id`: Reference to membership (optional)

## Login Flow

```
User submits credentials (username, password)
    ↓
AuthCubit.login() → emit(AuthLoading)
    ↓
AuthRepository.login()
    ↓
AuthRemoteDataSource.login()
    ↓
Query Firestore: users.where('username' == input)
    ↓
Compare password
    ↓
IF password matches:
  - Create UserModel
  - SessionManager.saveUserSession()
  - emit(AuthAuthenticated(user))
ELSE:
  - emit(AuthError("كلمة المرور غير صحيحة"))
```

## Session Restoration Flow

On app startup (`main()` calls `checkExistingSession()`):

```
AuthCubit.checkExistingSession()
    ↓
AuthRepository.getCurrentUser()
    ↓
AuthRemoteDataSource.getCurrentUser()
    ↓
SessionManager.getSavedUserSession()
    ↓
IF session exists:
  - Verify user exists in Firestore
  - Return UserModel
  - emit(AuthSessionRestored(user))
ELSE:
  - emit(AuthUnauthenticated)
```

## Logout Flow

```
User clicks logout
    ↓
AuthCubit.logout()
    ↓
AuthRepository.logout()
    ↓
AuthRemoteDataSource.logout()
    ↓
SessionManager.clearUserSession()
    ↓
emit(AuthUnauthenticated)
```

## Firestore Seeding

### Seeding Utility (`core/utils/firestore_seeder.dart`)

Automatically seeds test users on first app run:

```dart
FirestoreSeeder.seedUsers(
  firestore: FirebaseFirestore.instance,
  overwrite: false, // Set to true to reset users
);
```

### Test Users (Default)

| Username | Password | Membership ID | Role     |
| -------- | -------- | ------------- | -------- |
| abadr    | 123      | 1036711       | member   |
| badr     | 123      | 1036711       | child    |
| hamdy    | 123      | -             | security |
| mennah   | 123      | 1036711       | wife     |

## Integration with DI Container

The `injection_container.dart` registers:

1. **SharedPreferences**: Singleton for local storage
2. **SessionManager**: Singleton for session handling
3. **FirebaseFirestore**: Singleton for Firestore access
4. **AuthRemoteDataSource**: Lazy singleton receiving dependencies

## Error Handling

The implementation handles:

- **User not found**: "مستخدم غير موجود"
- **Wrong password**: "كلمة المرور غير صحيحة"
- **Session cleared**: User logged out and session cleared
- **Firestore errors**: Rethrown to Cubit with full error message

## Security Considerations

⚠️ **Current Implementation Notes:**

- Passwords are stored in plain text (for development)
- For production, implement:
  - Password hashing (bcrypt, scrypt)
  - HTTPS-only transmission
  - Firestore security rules
  - Rate limiting on login attempts
  - Token-based session management (JWT)

## Usage in Screens

### Login Screen Example

```dart
context.read<AuthCubit>().login(username, password);

// Listen to state changes
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // Navigate to home
    } else if (state is AuthError) {
      // Show error message
    }
  },
  child: // UI
);
```

### Access Current User

```dart
context.watch<AuthCubit>().state
```

## Future Enhancements

1. Password hashing with proper algorithms
2. Email verification
3. Two-factor authentication
4. Password reset functionality
5. User role-based permissions
6. Refresh token mechanism
7. Device fingerprinting
8. Login history tracking
