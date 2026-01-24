# PostManager

DummyJSON Posts API를 기반으로  
오프라인에서도 게시글 CRUD가 가능하도록 구현한 iOS 앱입니다.

로컬 저장소를 중심으로 데이터를 관리하고,  
온라인 전환 시 변경 사항을 서버로 동기화하는 구조를 적용했습니다.

## 개발 환경
- iOS
- Swift
- UIKit (Code-based)
- MVVM
- RxSwift / RxCocoa
- Swift Package Manager
- GRDB (Local Database)

## 주요 기능
- 게시글 목록 조회 (페이지네이션)
- 게시글 생성 / 수정 / 삭제
- 오프라인 CRUD 지원
- 온라인 전환 시 동기화 처리
- 대시보드 통계 정보 표시
