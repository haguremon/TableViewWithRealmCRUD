//
//  Tasks.swift
//  TableViewWithRealmCRUD
//
//  Created by IwasakIYuta on 2021/08/12.
//

import Foundation
import RealmSwift

class Tasks : Object {
    @objc dynamic var task: String = ""
    @objc dynamic var memo: String = ""
    @objc dynamic var createAt = ""
    @objc dynamic var id = 0
}

//ここでTasksの配列を持つプロパティを用意
class TasksList: Object {
   
    var tasksList = List<Tasks>()
    
}
