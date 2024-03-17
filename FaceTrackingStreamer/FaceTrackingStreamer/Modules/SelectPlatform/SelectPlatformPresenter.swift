//
//  SelectPlatformPresenter.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

final class SelectPlatformPresenter: BaseModuleOutput, ISelectPlatformPresenter {
    
    private weak var view: ISelectPlatformView?
    
    private let platformManager: IPlatformManager
    private let channelService: IChannelService
    
    init(
        view: ISelectPlatformView,
        platformManager: IPlatformManager,
        channelService: IChannelService,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.platformManager = platformManager
        self.channelService = channelService
        super.init(coordinator: coordinator)
    }
    
    func onContinueTapped(platform name: String?) {
        let model = ChannelModel(channel: name ?? "")
        channelService.validate(channel: model) { [weak self] result in
            switch result {
            case .success(let data):
                self?.platformManager.selectPlatform(name)
                self?.finish(.selectPlatformContinue(isLiveChannel: data.isLive))
            case .failure:
                self?.finish(.selectPlatformValidationError)
            }
        }
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
