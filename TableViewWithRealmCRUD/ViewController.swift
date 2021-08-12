//
//  ViewController.swift
//  TableViewWithRealmCRUD
//
//  Created by IwasakIYuta on 2021/08/12.
//あ

import UIKit
import RealmSwift

class ViewController: UIViewController {
    static let cellid = "cell"
    let realm = try! Realm()
    var tasks: Results<Tasks>!
    var tasksList: List<Tasks>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        createTasksDataAll()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    @IBAction func taskAddBarButton(_ sender: UIBarButtonItem) {
        let dalog = UIAlertController(title: "taskAdd", message: "タスクを追加します", preferredStyle: .alert)
        dalog.addTextField(configurationHandler: nil)//dalogにTextFieldを加える//アクションシートにはテキストフィールドは加えることができない
        let createTaskAction = UIAlertAction(title: "createTask", style: .default) { [weak self] _ in
            //field⇨dalogでtextFieldが追加されてるか判断して、text⇨textFieldsのテキストを取得する
            guard let field = dalog.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }
            //クロージャ内でselfに参照するのでweakをつけて弱参照にしてる
            self?.newTaskData(task: text)
        }
        //createTasksDataAll()
        dalog.addAction(createTaskAction)
        present(dalog, animated: true, completion: nil)
    }
   
    //RealmSwiftのCRUD等
    func createTasksDataAll() {
        
        tasks = realm.objects(Tasks.self)
        tasksList = realm.objects(TasksList.self).first?.tasksList
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
       
        
    }
//値の保存
    func newTaskData(task: String){
        let tasks = Tasks()
        tasks.task = task
        do {
            
            try realm.write({
                
                if tasksList == nil {
                    
                    let tasksList = TasksList()
                    
                    tasksList.tasksList.append(tasks)
                    
                    realm.add(tasksList)
                   
                } else {
                    
                    tasksList.append(tasks)
                   
                }
            
            })
        } catch {
            
            print(error)
        
        }
        createTasksDataAll()
    }
    
    func upDateTasksData(task: Tasks, newTask: String){
        let predicate = NSPredicate(format: "task == %@",task.task)//task一致したやつを指定
        tasks = realm.objects(Tasks.self).filter(predicate)
        do {
            try realm.write({
                tasks.first?.task = newTask
            createTasksDataAll()
            })
        } catch {
            print(error)
        }
    
    }
    //上と似てるから変更できそう
    func upTasksMemo(task: Tasks, upMemo: String){
        let predicate = NSPredicate(format: "memo == %@",task.memo)//memo一致したやつを指定
        tasks = realm.objects(Tasks.self).filter(predicate)
        do {
            try realm.write({
                tasks.first?.memo = upMemo
            })
        } catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.createTasksDataAll()
        }
    
    }
    
    func deleteTasksData(task: Tasks){
    
    
    }


}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: ViewController.cellid, for: indexPath)
        cell.textLabel?.text = tasksList[indexPath.row].task
        return cell
    }
    
    
    
}
