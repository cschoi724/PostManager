## PostManager

오프라인에서도 게시글을 생성/수정/삭제하고, 네트워크가 복구되면 자동으로 서버와 동기화되는 iOS 데모 앱입니다.  
Core Data를 단일 진실 소스(SSOT)로 사용하고, DummyJSON API는 항상 로컬 상태를 보강하는 용도로만 사용합니다.

---

### 사용 기술 스택

- **언어/플랫폼**: Swift, iOS
- **UI 레이어**: UIKit (코드 기반), Auto Layout(SnapKit), Then
- **아키텍처**: Clean Architecture, MVVM + UseCase + Repository + Local/Remote DataSource
- **반응형 바인딩**: RxSwift / RxCocoa
- **로컬 저장소**: Core Data (`CoreDataStack`, `PostEntity`)
- **네트워크**: `URLSession` 기반 `NetworkClient` + `PostsAPI` (DummyJSON)

---

### 주요 기능

- **게시글 리스트**
  - Core Data 기반 무한 스크롤 리스트 (페이지네이션)
  - 게시글 생성/수정/삭제 (온라인/오프라인 공통)
  - 대시보드에서 수정/삭제해도 리스트에 자동 반영

- **대시보드**
  - 전체 게시글/오프라인 생성/동기화 필요 개수 카드
  - 최근 게시글 5개 목록
  - 모든 카운트는 **로컬 DB만 기준**으로 계산

### 동기화 전략 

- **SSOT**
  - `Post` 엔티티가 `localId`, `remoteId`, `syncStatus(.synced/.created/.updated/.deleted)`,
    `isSoftDeleted` 를 포함합니다.
  - 모든 화면은 `PostsRepository` → `CoreDataPostsLocalDataSource`를 통해서만 데이터를 읽습니다.
  - 서버 GET 결과는 `mergeRemotePosts`를 통해 **로컬에 upsert**만 수행하며, 직접 UI에 사용하지 않습니다.

- **CRUD 동작**
  - 항상 로컬 먼저 반영 (오프라인/온라인 공통):
    - Create: `syncStatus = .created`, `isSoftDeleted = false`
    - Update: `syncStatus = .updated`
    - Delete: `isSoftDeleted = true`, `syncStatus = .deleted` (tombstone)
  - 온라인일 때는 서버 `POST/PUT/DELETE`를 **best-effort**로 호출하고,
    실패하더라도 에러를 전파하지 않고 `syncStatus`를 pending 상태로 유지합니다.

- **Sync 엔진 (`syncPendingChanges`)**
  - `fetchPostsNeedingSync()`로 `syncStatus != .synced` 인 모든 포스트(soft delete 포함)를 조회합니다.
  - 각 포스트에 대해:
    - `.created` → `POST /posts/add` → 성공 시 `remoteId` 설정 + `syncStatus = .synced`
    - `.updated` → `PUT /posts/{id}` (또는 `remoteId` 없으면 `POST`) → 성공 시 `syncStatus = .synced`
    - `.deleted` → `DELETE /posts/{id}` (있으면) → 성공 시 Core Data에서 완전 삭제
  - 개별 항목 동기화 실패는 전체를 막지 않고, 해당 포스트는 계속 pending 상태로 남아 다음 sync 때 재시도됩니다.

### 대시보드 카운트 규칙

- **전체 게시글**
  - `isSoftDeleted == false` 인 게시글 수

- **오프라인 생성**
  - `syncStatus == .created` 인 게시글 수  
    (서버에 아직 반영되지 않은 pending create)

- **동기화 필요**
  - `syncStatus != .synced` 인 모든 게시글 수  
    (`.created + .updated + .deleted`, soft delete 포함)

---

### 의존성 방향

본 프로젝트는 Clean Architecture 원칙에 따라 의존성 방향을 명확히 분리했습니다.

- **Presentation → Domain ← Data**
  - Presentation 레이어는 Domain에만 의존합니다.
  - Data 레이어 역시 Domain에만 의존하며, Presentation에는 의존하지 않습니다.
  - Domain 레이어는 어떤 외부 레이어에도 의존하지 않는 순수한 중심 레이어입니다.

- **App → Presentation, Domain, Data**
  - App 레이어는 각 레이어를 조립(composition)하는 역할만 담당합니다.
  - 실제 구현체는 App 레이어에서 주입되며, 각 레이어는 인터페이스를 통해서만 연결됩니다.
