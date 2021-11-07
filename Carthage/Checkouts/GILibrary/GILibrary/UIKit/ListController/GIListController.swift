//
//  GIListController.swift
//  GILibrary
//
//  Created by Gin Imor on 5/12/21.
//  
//

import UIKit

open class GIListCell<Row>: UITableViewCell {
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func setup() {
    backgroundColor = .white
  }
  
  open var row: Row? {
    didSet { didSetRow() }
  }
  
  open func didSetRow() {}
}

open class GIListController<Row>: UITableViewController {
  
  open var rowCellClass: GIListCell<Row>.Type? { nil }
  
  let rowCellId = "rowCellId"

  open var list: [Row] = []
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func setList(_ list: [Row]) {
    self.list = list
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
  }
  
  open func setupTableView() {
    tableView.backgroundColor = .white
    tableView.tableFooterView = UIView()
    tableView.register(rowCellClass, forCellReuseIdentifier: rowCellId)
  }
  
  open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    list.count
  }
  
  open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: rowCellId, for: indexPath) as! GIListCell<Row>
    cell.row = list[indexPath.row]
    return cell
  }
  
}
