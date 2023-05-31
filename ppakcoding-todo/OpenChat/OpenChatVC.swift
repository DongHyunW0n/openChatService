//
//  OpenChatVC.swift
//  ppakcoding-todo
//
//  Created by WonDongHyun on 2023/05/30.
//

import UIKit
import FirebaseDatabase



class OpenChatVC: UIViewController {
    
    var ref: DatabaseReference?
    
   
    @IBOutlet weak var messageTableView: UITableView!
    
    var MessageList : [MessageEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database
            .database(url: "https://freechat-e9211-default-rtdb.firebaseio.com").reference().child("todos")
        
    
        
        // Listen for deleted comments in the Firebase database
        // 삭제가 일어났을때 만 받겠다
        ref?.observe(.childRemoved, with: { (snapshot) -> Void in
            guard let index : Int = self.todoList.firstIndex(where: { $0.refId == snapshot.key }) else { return }
            
            self.todoList.remove(at: index)
            
            let removingIndexPath = IndexPath(row: index, section: 0)
            
            self.todoTableView.deleteRows(at: [removingIndexPath], with: .fade)
        })
        
        // Listen for new comments in the Firebase database
        // 데이터 추가가 일어났을때 만 받겠다
        ref?.observe(.childAdded, with: { (snapshot) -> Void in
            
            let value = snapshot.value as? NSDictionary
            let todo = value?["todo"] as? String ?? ""
            let isDone = value?["isDone"] as? Bool ?? false
            
            let addedTodoEntity = TodoEntity(refId: snapshot.key,
                                               todo: todo, isDone: isDone)
            print(#fileID, #function, #line, "- addedTodoEntity: \(addedTodoEntity)")
            
            // 1. 데이터 추가
            self.todoList.append(addedTodoEntity)
            
            let appendingIndexPath = IndexPath(row: self.todoList.count - 1, section: 0)
            
            self.todoTableView.insertRows(at: [appendingIndexPath], with: .fade)
        })
        
        // 특정 데이터가 변경 되었을 때 만 받겠다
        ref?.observe(.childChanged, with: { (snapshot) -> Void in
            
            let value = snapshot.value as? NSDictionary
            let todo = value?["todo"] as? String ?? ""
            let isDone = value?["isDone"] as? Bool ?? false
            
            let changedTodoEntity = TodoEntity(refId: snapshot.key,
                                               todo: todo, isDone: isDone)
            print(#fileID, #function, #line, "- changedTodoEntity: \(changedTodoEntity)")
            
            guard let index : Int = self.todoList.firstIndex(where: { $0.refId == snapshot.key }) else { return }
            
            // 1. 데이터 변경
            self.todoList[index] = changedTodoEntity
            
            let changingIndexPath = IndexPath(row: index, section: 0)
            
            self.todoTableView.reloadRows(at: [changingIndexPath], with: .fade)
        })
        
    }
    
    @IBAction func addTodoBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        guard let userInput : String = todoInputTextField.text,
              userInput.count > 0 else {
            presentAlert()
            return
        }
        
        //        let newTodo = TodoEntity(todo: userInput, isDone: false)
        
        self.ref?
            .childByAutoId()
            .setValue([
                "todo": userInput,
                "isDone": false
            ] as [String : Any])
        
      
        
        todoInputTextField.text = ""
    }
    
    fileprivate func presentAlert(){
        let alert = UIAlertController(title: "안내",
                                      message: "할일이 비어있습니다", preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("확인", comment: "Default action"), style: .default, handler: { _ in
        })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func presentEditTodoAlert(currentTodo: TodoEntity,
                                          indexPath: IndexPath){
        let alert = UIAlertController(title: "수정",
                                      message: "할일을 수정해주세요", preferredStyle: .alert)
        
        alert.addTextField()
        
        let inputTF = alert.textFields?.first
        inputTF?.text = currentTodo.todo
        
        let editAction = UIAlertAction(title: NSLocalizedString("완료", comment: "Default action"), style: .default, handler: { [weak self] _ in
            guard let self = self,
                  let userInput = inputTF?.text else { return }
            
            let editingTodo = self.todoList[indexPath.row]
            
            self.ref?.child(editingTodo.refId)
                .updateChildValues(["todo": userInput], withCompletionBlock: {_,_ in })
            
            //            self.todoList[indexPath.row].todo = userInput
            //            self.todoTableView.reloadRows(at: [indexPath], with: .fade)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("닫기", comment: "Default action"), style: .cancel, handler: { _ in
        })
        
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension OpenChatVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTableViewCell", for: indexPath) as? TodoTableViewCell else  {
            return UITableViewCell()
        }
        
        let cellData : TodoEntity = todoList[indexPath.row]
        
        cell.configureCell(cellData)
        
        cell.isDoneAction = { [weak self] refId, isDone in
            guard let self = self else { return }
            print(#fileID, #function, #line, "- refId: \(refId), isDone: \(isDone)")
            
            self.ref?.child(refId)
                .updateChildValues(["isDone": isDone], withCompletionBlock: {_,_ in })
        }
        
        return cell
    }
}

extension OpenChatVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제", handler: { _,_,_  in
            print(#fileID, #function, #line, "- 삭제 : \(indexPath)")
            
            let todoToBeDeleted = self.todoList[indexPath.row]
            
            self.ref?.child(todoToBeDeleted.refId)
                .removeValue()
            
            //            // 1. 데이터 지우기
            //            self.todoList.remove(at: indexPath.row)
            //
            //            // 2. 쎌 리로드 혹은 지우기
            //            //            tableView.reloadData()
            //            tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        let cellConfig = UISwipeActionsConfiguration(actions: [
            deleteAction
        ])
        
        return cellConfig
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "수정", handler: { [weak self] _,_,_  in
            
            guard let self = self else { return }
            
            print(#fileID, #function, #line, "- 수정 : \(indexPath)")
            
            let currentTodo = self.todoList[indexPath.row]
            
            self.presentEditTodoAlert(currentTodo: currentTodo, indexPath: indexPath)
        })
        
        let cellConfig = UISwipeActionsConfiguration(actions: [
            editAction
        ])
        
        cellConfig.performsFirstActionWithFullSwipe = false
        
        return cellConfig
    }
}

