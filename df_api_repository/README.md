# df_api_repository

Base repository pattern for Dio-based APIs: shared pagination and single-resource helpers. Used by [DataFortress.cloud](https://datafortress.cloud/) apps (e.g. PsychDiary’s `DiaryRepository`). No Riverpod or app-specific code; just extend the base and implement your endpoints.

---

## What’s included

- **ApiRepositoryConfig** – Optional `defaultPageSize`, `connectTimeout`, `receiveTimeout`. Default page size is 20.
- **BaseApiRepository** – Abstract class with:
  - `final Dio dio` and optional `ApiRepositoryConfig config`
  - **getList\<T\>**(`path`, `skip`, `limit`, `queryParameters`, `fromJson`) – GET a list, merge skip/limit into query, map JSON to `T`
  - **getOne\<T\>**(`path`, `fromJson`) – GET a single JSON object and map to `T`

Your repository extends `BaseApiRepository`, passes `Dio` (and optionally config) from the constructor, and uses `dio` or `getList` / `getOne` for each endpoint.

---

## Setup

1. Add a path dependency:

   ```yaml
   dependencies:
     df_api_repository:
       path: ../packages/df_api_repository
   ```

2. In your app, create a repository that extends `BaseApiRepository`:

   ```dart
   import 'package:df_api_repository/df_api_repository.dart';

   class DiaryRepository extends BaseApiRepository {
     DiaryRepository(super.dio);

     Future<List<DiaryEntry>> listEntries({int skip = 0, int limit = 100}) async {
       return getList<DiaryEntry>(
         '/diary-entries',
         skip: skip,
         limit: limit,
         fromJson: DiaryEntry.fromJson,
       );
     }

     Future<DiaryEntry> getEntry(int id) async {
       return getOne<DiaryEntry>('/diary-entries/$id', fromJson: DiaryEntry.fromJson);
     }
     // ... createEntry, updateEntry, deleteEntry using dio.post/put/delete
   }
   ```

3. Provide `Dio` (e.g. from `df_firebase_auth`’s `apiClientProvider`) when constructing the repository.

---

## Dependencies

- `flutter` (SDK), `dio`. No Riverpod.
