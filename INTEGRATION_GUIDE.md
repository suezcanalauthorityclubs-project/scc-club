# Auth Module Integration Guide

## Setup Instructions

### 1. Dependencies Added

```yaml
shared_preferences: ^2.2.2
```

### 2. New Files Created

```
lib/
├── core/
│   ├── services/
│   │   └── session_manager.dart (new)
│   └── utils/
│       └── firestore_seeder.dart (new)
├── features/auth/
│   └── AUTH_MODULE_README.md (documentation)
```

### 3. Updated Files

- `lib/main.dart` - Added seeding and session check
- `lib/core/di/injection_container.dart` - Registered new services
- `lib/features/auth/domain/entities/user_entity.dart` - New fields
- `lib/features/auth/data/models/user_model.dart` - Updated structure
- `lib/features/auth/data/datasources/auth_remote_data_source_impl.dart` - Firestore implementation
- `lib/features/auth/presentation/cubit/auth_cubit.dart` - Session management
- `lib/features/auth/presentation/cubit/auth_state.dart` - New state
- `pubspec.yaml` - Added dependency

## What Changed

### From Firebase Auth To Firestore

**Before:**

- Firebase Authentication SDK (email/password)
- Separate user profiles in Firestore
- Firebase session management

**After:**

- Direct Firestore collection queries (users)
- Custom password verification
- SharedPreferences for session persistence
- Manual session lifecycle management

### User Data Structure

**Previous Fields:**

- id, name, email, phone, role, membershipType, status

**New Fields:**

- id, username, role, membershipId

## Usage Examples

### Initialize Session on Startup

```dart
// Already done in main()
AuthCubit authCubit = di.sl<AuthCubit>();
await authCubit.checkExistingSession();
```

### Login

```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      final user = state.user;
      print('Logged in: ${user.username}');
      // Navigate to home
      Navigator.pushReplacementNamed(context, Routes.home);
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      if (state is AuthLoading) {
        return Center(child: CircularProgressIndicator());
      }
      return LoginForm();
    },
  ),
);
```

### Access Current User

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated || state is AuthSessionRestored) {
      final user = (state as dynamic).user;
      return Text('Welcome ${user.username}');
    }
    return Text('Not logged in');
  },
);
```

### Logout

```dart
context.read<AuthCubit>().logout();
```

## Seeding Firestore

### Manual Seeding

Run this in your IDE console or add to a dedicated endpoint:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sca_members_clubs/core/utils/firestore_seeder.dart';

await FirestoreSeeder.seedUsers(
  firestore: FirebaseFirestore.instance,
  overwrite: true, // Set to true to replace existing users
);
```

### Auto Seeding

The `main()` function automatically seeds users on first run:

```dart
// In main.dart
await FirestoreSeeder.seedUsers(
  firestore: FirebaseFirestore.instance,
  overwrite: false, // Won't overwrite existing data
);
```

## Default Test Credentials

| Username | Password | Role     | Membership |
| -------- | -------- | -------- | ---------- |
| abadr    | 123      | member   | 1036711    |
| badr     | 123      | child    | 1036711    |
| hamdy    | 123      | security | -          |
| mennah   | 123      | wife     | 1036711    |

## Testing

### Test Login Flow

```dart
// In your test
expect(find.byType(AuthLoading), findsWidgets);
expect(find.byType(AuthAuthenticated), findsWidgets);
```

### Test Session Persistence

```dart
// After login, close and reopen app
// Session should be automatically restored
expect(authCubit.state, isA<AuthSessionRestored>());
```

## Migration Checklist

If migrating from previous auth:

- [ ] Review all screens using auth state
- [ ] Update any username references (previously email/identifier)
- [ ] Test login with test credentials
- [ ] Verify session restoration
- [ ] Test logout and session clearing
- [ ] Update error messages to reflect new fields
- [ ] Test with slow network (loading states)
- [ ] Verify Firestore rules allow user queries

## Troubleshooting

### Users not seeding

- Check Firestore has internet connection
- Verify Firebase rules allow write access
- Check console logs for errors
- Try `overwrite: true` to force seed

### Session not restoring

- Check SharedPreferences is initialized
- Verify SessionManager is in DI container
- Check local storage isn't cleared

### Login always fails

- Verify username exact match in Firestore
- Check password comparison (case-sensitive)
- Confirm user document exists in users collection

## Security Improvements TODO

- [ ] Add password hashing
- [ ] Implement Firestore security rules
- [ ] Add login attempt rate limiting
- [ ] Add session timeout
- [ ] Implement JWT tokens
- [ ] Add refresh token mechanism
