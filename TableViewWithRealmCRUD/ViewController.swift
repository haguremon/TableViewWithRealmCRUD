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
    
    
    
    let randommark = ["@","#","$","^","&","*","("]
   
   
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        createTasksDataAll()
       // tableView.isEditing = true
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    @IBAction func editingSegmented(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tableView.isEditing = false
        } else  {
        tableView.isEditing = true
    
        }
    }
    
    
    @IBAction func taskAddBarButton(_ sender: UIBarButtonItem) {
        let dalog = UIAlertController(title: "taskAdd", message: "タスクを追加します", preferredStyle: .alert)
        dalog.addTextField(configurationHandler: nil)//dalogにTextFieldを加える//アクションシートにはテキストフィールドは加えることができない
        let createTaskAction = UIAlertAction(title: "createTask", style: .default) { [weak self] _ in
            //field⇨dalogでtextFieldが追加されてるか判断して、text⇨textFieldsのテキストを取得する
            guard let field = dalog.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }
            //self?.count += 1
            //クロージャ内でselfに参照するのでweakをつけて弱参照にしてる
            self?.newTaskData(task: text)
        }
        dalog.addAction(createTaskAction)
        
       dalog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
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
        
        let count = Int.random(in: 0...55)
        
        let id = String(count) + randommark.randomElement()!
        
        if tasks.id.contains(id) {
            
            tasks.id = String(count) + randommark.randomElement()!
        
        } else {
           
            tasks.id = id

            
        }
        
        //重複しないiDを持たせたい場合はプライマリーキーをつけるといい
        // print(count)
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
        //let predicate = NSPredicate(format: "task == %@",task.task)//task一致したやつを指定
        do {
            try realm.write {
                //self.tasks.removeAll()
                realm.delete(task)
                createTasksDataAll()
            }
        } catch  {
            print(error)
        }
    
    }
    
    func searchingData(task: String) {
        
        let predicate = NSPredicate(format: "task == %@",task)//name一致したやつを指定
        
    let tasks = realm.objects(Tasks.self).filter(predicate)
        
        //fetchRequest.predicate = predicate
        self.tasks = tasks
        
        DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        
    }
    func searchResultdalog(message: String){
        let dalog = UIAlertController(title: "検索結果", message: message, preferredStyle: .alert)
        dalog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
       present(dalog, animated: true, completion: nil)
    }
    
    
    @IBAction func searchingButton(_ sender: UIButton) {
        guard let task = textField.text, !task.isEmpty  else {
            searchResultdalog(message: "値を入れてください")
            return
            
        }
        searchingData(task: task)
        
        guard !tasks.isEmpty else {
            searchResultdalog(message: "値がヒットしませんでした")
            
            createTasksDataAll()
            
            return
        }
        searchResultdalog(message: "\(tasks.count)件ヒットしました")
            
         
 
        
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            self.createTasksDataAll()
       
        }
        

    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: ViewController.cellid, for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].task
        return cell
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete //デリートで指定
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            
            if editingStyle == .delete {
                tableView.beginUpdates()
                
//                try! realm.write { //realm.writeで削除処理することができる
//                self.realm.delete(tasks[indexPath.row])
//                }
                deleteTasksData(task: tasks[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
            }
    
    
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //並び替えをするときは List<Element>を定義してやった方がやりやすい
        try! realm.write { //realm.writeで削除処理することができる
            let task = tasksList[sourceIndexPath.row]
            tasksList.remove(at: sourceIndexPath.row)//動かすのを処理して
            //upDateTasksData(task: [destinationIndexPath.row], newTask: tasks[sourceIndexPath.row].task)
            tasksList.insert(task, at: destinationIndexPath.row)
        }
        
    }
   
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //didSelectRowAtでそこをタップ
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        //dalogSheetが３つ出る
        let dalogSheet = UIAlertController(title: "taskAdd", message: "Task management", preferredStyle: .actionSheet)
        dalogSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        dalogSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [ weak self ] _ in
            
            //Editが選べれた時に
            let dalog = UIAlertController(title: "Edit", message: "TaskEdit", preferredStyle: .alert)
            //dalogにTextFieldを加える
            dalog.addTextField(configurationHandler: nil)
            //ここでtextFieldsにタップされたタスクを表示させる
            dalog.textFields?.first?.text = task.task
            
            
            //ここでアラートを出す
            let EditTask = UIAlertAction(title: "EditTask", style: .default) { [ weak self]  _ in
              //EditTaskがタップされた時に
                //fieldでdalogでtextFieldが追加されてるか判断して⇨textでtextFieldsのテキストを取得する
                
                guard let field = dalog.textFields?.first, let editText = field.text, !editText.isEmpty else{
            //fieldがaddTextFieldされてるか判断してそして、その中の値が空でない場合とeditTextの場合
            //↓でupDateTasksDataをすることができる
                    return
                
                }
                //クロージャ内でselfに参照するのでweakをつけて弱参照にしてる
                self?.upDateTasksData(task: task, newTask: editText)
            }
            dalog.addAction(EditTask)
            self?.present(dalog, animated: true)
            
        }))
        //deleteをタップされた時にそこで選択されてるタスクをdeleteTasksDatで削除することができる
        dalogSheet.addAction(UIAlertAction(title: "delete", style: .destructive, handler: {[weak self] _ in
            
            self?.deleteTasksData(task: task)
            
        }))
        
        present(dalogSheet, animated: true)
    }
}
