//
//  AppDIContainer.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public final class AppDIContainer {
    
    private lazy var networkClient: NetworkClient = {
        DefaultNetworkClient()
    }()
    
    private lazy var postsRemoteDataSource: PostsRemoteDataSource = {
        PostsRemoteDataSourceImpl(networkClient: networkClient)
    }()
    
    private lazy var networkMonitor: NetworkMonitor = {
        NetworkMonitorImpl()
    }()
    
    private lazy var coreDataStack: CoreDataStack = {
        CoreDataStack(name: "PostsModel")
    }()
    
    private lazy var postsLocalDataSource: PostsLocalDataSource = {
        CoreDataPostsLocalDataSource(coreDataStack: coreDataStack)
    }()
    
    private lazy var postsRepository: PostsRepository = {
        PostsRepositoryImpl(
            remoteDataSource: postsRemoteDataSource,
            localDataSource: postsLocalDataSource,
            networkMonitor: networkMonitor
        )
    }()
    
    public init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        NotificationCenter.default.addObserver(
            forName: .networkDidBecomeOnline,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                guard let self else { return }

                let sync = await self.makeSyncPostsUseCase()
                try? await sync()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func makePostsRepository() -> PostsRepository {
        return postsRepository
    }
    
    public func makeNetworkMonitor() -> NetworkMonitor {
        return networkMonitor
    }
    
    public func makeFetchPostsUseCase() -> FetchPostsUseCase {
        FetchPostsUseCaseImpl(repository: makePostsRepository())
    }
    
    public func makeLoadMorePostsUseCase() -> LoadMorePostsUseCase {
        LoadMorePostsUseCaseImpl(
            repository: makePostsRepository(),
            networkMonitor: makeNetworkMonitor()
        )
    }
    
    public func makeFetchPostUseCase() -> FetchPostUseCase {
        FetchPostUseCaseImpl(repository: makePostsRepository())
    }
    
    public func makeCreatePostUseCase() -> CreatePostUseCase {
        CreatePostUseCaseImpl(repository: makePostsRepository())
    }
    
    public func makeUpdatePostUseCase() -> UpdatePostUseCase {
        UpdatePostUseCaseImpl(repository: makePostsRepository())
    }
    
    public func makeDeletePostUseCase() -> DeletePostUseCase {
        DeletePostUseCaseImpl(repository: makePostsRepository())
    }
    
    public func makeSyncPostsUseCase() -> SyncPostsUseCase {
        SyncPostsUseCaseImpl(repository: makePostsRepository())
    }
    
    public func makeFetchDashboardUseCase() -> FetchDashboardUseCase {
        FetchDashboardUseCaseImpl(repository: makePostsRepository())
    }
}
