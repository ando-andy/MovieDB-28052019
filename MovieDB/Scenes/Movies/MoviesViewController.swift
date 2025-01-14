//
//  MoviesViewController.swift
//  MovieDB
//
//  Created by nguyen.van.hungd on 5/27/19.
//  Copyright © 2019 nguyen.van.hungd. All rights reserved.
//

import UIKit
import Reusable
import RxDataSources

final class MoviesViewController: UIViewController, BindableType {
    
    // MARK: Outlets

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var viewModel: MoviesViewModel!
    
    var moviesBanners = [Movie]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var categoryList = [CategoryType]()
    
    fileprivate var showAllCategoryTrigger = PublishSubject<IndexPath>()
    fileprivate var showSearchScreenTrigger = PublishSubject<Void>()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.do {
            $0.navigationBar.prefersLargeTitles = true
            $0.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: Methods
    
    private func configView() {
        self.title = "Movies"
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "search"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(handleClickSearch))
        rightBarButton.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButton
        
        tableView.do {
            $0.rowHeight = 200
            $0.register(cellType: CategoryCell.self)
            $0.delegate = self
            $0.dataSource = self
        }
    }
    
    @objc private func handleClickSearch() {
        showSearchScreenTrigger.onNext(())
    }
    
    func bindViewModel() {
        let input = MoviesViewModel.Input(
            loadTrigger: Driver.just(()),
            selectedCategoryTrigger: showAllCategoryTrigger.asDriverOnErrorJustComplete(),
            searchMovieTrigger: showSearchScreenTrigger.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input)
        
        output.movieCategoryList
            .drive(movies)
            .disposed(by: rx.disposeBag)
        
        output.movieBannerList
            .drive(headerView)
            .disposed(by: rx.disposeBag)
        
        output.selectedCategory
            .drive()
            .disposed(by: rx.disposeBag)
        
        output.searchMovie
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

extension MoviesViewController {
    var headerView: Binder<[Movie]> {
        return Binder(self) { viewController, data in
            viewController.moviesBanners = data
        }
    }
    
    var movies: Binder<[CategoryType]> {
        return Binder(self) { viewController, categoryList in
            viewController.categoryList = categoryList
            viewController.tableView.reloadData()
        }
    }
}

extension MoviesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CategoryCell.self)
            .then {
                $0.categoryLabel.text = self.categoryList[indexPath.row].categoryTitle
                $0.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                $0.showAllAction = { [weak self] in
                    self?.showAllCategoryTrigger.onNext(IndexPath(item: indexPath.row, section: 0))
                }
        }
        return cell
    }
}

extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MoviesHeaderView.loadFromNib()
        header.movieBannerList = moviesBanners
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension MoviesViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

extension MoviesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return categoryList[collectionView.tag].movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MovieCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.bindingCell(MovieViewModel(movie: categoryList[collectionView.tag].movies[indexPath.row]))
        return cell
    }
}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        let width = height * 2 / 3
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
