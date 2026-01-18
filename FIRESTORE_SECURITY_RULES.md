# Firestore Security Rules for Auth Module

## ⚠️ Important

These are suggested security rules for production. Apply them via Firebase Console → Firestore → Rules tab.

## Development Rules (INSECURE - Use Only for Testing)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes (DEVELOPMENT ONLY)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Production Rules (RECOMMENDED)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users Collection Rules
    match /users/{userId} {
      // Allow user to read their own document
      allow read: if request.auth != null && request.auth.uid == userId;

      // Allow app to query by username (for login)
      allow read: if request.query.limit <= 1 &&
                     resource.data.username == request.query.username;

      // Prevent direct writes from client
      allow write: if false;

      // Allow admin role to manage users
      allow read, write: if request.auth.token.admin == true;
    }

    // Restrict writes to specific field patterns
    match /users/{userId} {
      allow create: if request.auth.token.admin == true;
      allow update: if request.auth.token.admin == true;
      allow delete: if request.auth.token.admin == true;
    }
  }
}
```

## Enhanced Production Rules (With Claims)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isAdmin() {
      return request.auth.token.role == 'admin';
    }

    function isSecurity() {
      return request.auth.token.role == 'security';
    }

    function isOwnData(userId) {
      return request.auth.uid == userId;
    }

    // Users Collection
    match /users/{userId} {
      // Allow reading own user data
      allow read: if isAuthenticated() && isOwnData(userId);

      // Allow login query (read only, specific fields)
      allow read: if request.query.limit <= 1;

      // Allow admins full access
      allow read, write: if isAdmin();

      // Allow security personnel to read user data
      allow read: if isSecurity();

      // Prevent client-side writes
      allow write: if false;
    }

    // Main Membership Collection (if relevant)
    match /main_membership/{membershipId} {
      allow read: if isAuthenticated();

      // Only members with matching membership_id can edit
      allow write: if isAdmin() ||
                      (request.auth.token.membership_id == membershipId);
    }
  }
}
```

## Alternative: Simple Read-Only for Login

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      // Only allow login queries (username lookup)
      allow read: if request.query.limit <= 1 &&
                     'username' in request.query;

      // Read own profile
      allow read: if request.auth != null &&
                     request.auth.uid == userId;

      // Block all writes from client
      allow write: if false;
    }
  }
}
```

## Note on User IDs

The current implementation uses **username as document ID**. For production, consider:

### Option 1: Email/Phone as ID (Current)

```
users/abadr
users/badr
users/hamdy
```

**Pros**: Matches login identifier  
**Cons**: Can't change username; security issue if exposed

### Option 2: UUIDs as ID (Recommended)

```
users/550e8400-e29b-41d4-a716-446655440000
users/6ba7b810-9dad-11d1-80b4-00c04fd430c8
```

**Pros**: Immutable, secure, scalable  
**Cons**: Need separate username index

### Option 3: Firebase Auth UID

```
users/{uid}  // where uid is from Firebase Auth
```

**Pros**: Integrates with other Firebase services  
**Cons**: Requires Firebase Auth setup

## Implementation Steps

1. **Go to Firebase Console**

   - Project Settings → Firestore → Rules Tab

2. **Replace Rules**

   - Copy and paste recommended rules above
   - Click "Publish"

3. **Test Rules**

   - Use Firebase Emulator Suite (recommended)
   - Test login scenarios
   - Test unauthorized access blocking

4. **Monitor**
   - Set up Firestore monitoring
   - Alert on denied reads/writes
   - Review access logs

## Testing Rules in Emulator

```bash
# Start emulator
firebase emulators:start

# In your app, use emulator during dev:
await FirebaseFirestore.instance.settings =
  Settings(persistenceEnabled: false);
```

## Security Checklist

- [ ] Enable Firestore Security Rules
- [ ] Restrict direct client writes
- [ ] Rate limit login queries
- [ ] Enable Firestore audit logs
- [ ] Set up monitoring alerts
- [ ] Test rules before production
- [ ] Use IP whitelisting if possible
- [ ] Enable encryption at rest
- [ ] Regular security audits
- [ ] Keep Firebase SDK updated

## Related Collections to Secure

```
// Main Membership
match /main_membership/{membershipId} {
  allow read: if request.auth.token.membership_id == membershipId;
  allow write: if request.auth.token.role == 'admin';
}

// Profile Data
match /profiles/{userId} {
  allow read: if request.auth.uid == userId ||
                 request.auth.token.role == 'admin';
  allow write: if request.auth.uid == userId;
}

// Activity Logs
match /activity_logs/{logId} {
  allow read: if request.auth.token.role == 'admin';
  allow write: if false;  // Server-side only
}
```

## Firestore Indexes

For optimized queries, create these indexes:

```
Collection: users
Fields:
  - username (Ascending)
  - role (Ascending)

Collection: main_membership
Fields:
  - membership_id (Ascending)
  - active (Ascending)
```

## Performance Optimization

### Query Limits

- Set appropriate limits for list queries
- Use pagination for large datasets
- Avoid unbounded queries

### Caching

- Cache user data in SharedPreferences
- Implement cache invalidation
- Use TTL for cached data

### Batch Operations

- Combine related reads/writes
- Use transactions for consistency
- Batch delete for cleanup

---

**Apply these rules before going to production!**  
**Never leave default "allow all" rules in production.**
