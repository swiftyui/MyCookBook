import Foundation
import CloudKit
import UIKit

class GroceryModel: ObservableObject {
    
    ///Variables
    @Published var groceryList: [GroceryList] = []
    @Published var isLoading: Bool = false
    
    typealias CompletionHandler = (_ success: Bool) -> Void
    
    func toggleLoading() {
        self.isLoading.toggle()
    }
    
    func updateGroceryList(groceryList: GroceryList, completion: @escaping (Bool) -> ()) {
        
        ///create a filter Predicate
        let filter = groceryList.id
        let predicate = NSPredicate(format: "id == %@", filter)
        
        ///create the Query
        let query = CKQuery(recordType: "GroceryList", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        ///create the Operation
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["id", "name", "items", "image"]
        database.add(operation)
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if( cursor != nil)
                {
                    let NewOperation = CKQueryOperation(cursor: cursor.unsafelyUnwrapped)
                    NewOperation.queryResultBlock = operation.queryResultBlock
                    NewOperation.recordMatchedBlock = operation.recordMatchedBlock
                    database.add(NewOperation)
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        //record match
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                
                ///update the record
                let encoder = JSONEncoder()
                let encodedArray = try! encoder.encode(groceryList.items)
                
                ///get the image as an asset
                guard
                    let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(groceryList.image.description),
                    let data = groceryList.image.jpegData(compressionQuality: 1.0) else { return }
                
                do{
                    try data.write(to: url)
                } catch let error {
                    print(error.localizedDescription)
                }
                let asset = CKAsset(fileURL: url)
                
                record.setValuesForKeys([
                    "id": groceryList.id,
                    "name": groceryList.name,
                    "items": encodedArray,
                    "image": asset
                ])
                
                database.save(record, completionHandler: { record, error in
                    completion(true)
                })
                
            case.failure(let error):
                print(error)
            }
        }
    }
    
    ///delete grocery list
    func deleteGroceryList(groceryList: GroceryList, completion: @escaping (Bool) -> ()) {
        
        ///create a filter Predicate
        let filter = groceryList.id
        let predicate = NSPredicate(format: "id == %@", filter)
            
        ///create the Query
        let query = CKQuery(recordType: "GroceryList", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
        ///create the Operation
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["id", "name", "items", "image"]
        database.add(operation)
            
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if( cursor != nil)
                {
                    let NewOperation = CKQueryOperation(cursor: cursor.unsafelyUnwrapped)
                    NewOperation.queryResultBlock = operation.queryResultBlock
                    NewOperation.recordMatchedBlock = operation.recordMatchedBlock
                    database.add(NewOperation)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
            
        //record match
        operation.recordMatchedBlock = { recordID, result in

                database.delete(withRecordID: recordID, completionHandler: { record, error in
                    completion(true)
                })
        }
    }
                
    
    func saveGroceryList(groceryList: GroceryList, completion: @escaping (Bool) -> ()) {
        
        self.isLoading = true
        
        ///Get the Food Items into an Array
        let encorder = JSONEncoder()
        let encodedArray = try! encorder.encode(groceryList.items)
        
        ///get the image as an asset
        guard
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(groceryList.image.description),
            let data = groceryList.image.jpegData(compressionQuality: 1.0) else { return }
        
        do{
            try data.write(to: url)
        } catch let error {
            print(error.localizedDescription)
        }
        let asset = CKAsset(fileURL: url)
            
        ///create a new CKRecord with the values
        let newRecord = CKRecord(recordType: "GroceryList")
        newRecord.setValuesForKeys([
            "id": groceryList.id,
            "name" : groceryList.name,
            "image": asset,
            "items": encodedArray
        ])
            
        ///save the new Record
        database.save(newRecord, completionHandler: { record, error in
            do { sleep(4) }
            completion(true)
        })
    }
    
    func loadGroceryLists(completion: @escaping (Bool) -> ()) {
        
        ///clear the grocery lists
        self.isLoading = true
        
        ///create the Query
        let query = CKQuery(recordType: "GroceryList", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        //create the database Operation
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 10
        database.add(operation)
        
        ///iteratively call until all is loaded
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if( cursor != nil)
                {
                    ///create a new operation with the cursor to fetch remaining data
                    let NewOperation = CKQueryOperation(cursor: cursor.unsafelyUnwrapped)
                    NewOperation.queryResultBlock = operation.queryResultBlock
                    NewOperation.recordMatchedBlock = operation.recordMatchedBlock
                    database.add(NewOperation)
                }
                else
                {
                    ///no more cursors we're done loading
                    completion(true)
                }

            case .failure(let error):
                print(error)
                completion(true)
            }
        }
        
        operation.recordMatchedBlock = { recordID, result in
            DispatchQueue.main.async {
                switch result {
                case .success(let record):
                    ///get the JSON array
                    let decorder = JSONDecoder()
                    var groceryList: GroceryList = GroceryList(id: "", name: "", items: [], addToList: false)

                    groceryList.id = record["id"] as! String
                    groceryList.name = record["name"] as! String

                    if(record["items"] != nil)
                    {
                        let data: Data = record["items"] as! Data
                        groceryList.items = try! decorder.decode([FoodItem].self, from: data)
                    }
                                        
                    //get the image
                    let imageAsset = record["image"] as? CKAsset
                    let imageURL = imageAsset?.fileURL
                    var uiImage = UIImage()
                    if (imageURL != nil)
                    {
                        let imageData = try? Data(contentsOf: imageURL.unsafelyUnwrapped)
                        uiImage = UIImage(data: imageData.unsafelyUnwrapped).unsafelyUnwrapped
                    } else {
                        uiImage = UIImage(named: "Food1").unsafelyUnwrapped
                    }
                    
                    groceryList.image = uiImage


                    //only add if it doesn't exist already
                    if !self.groceryList.contains(where: {$0.id == groceryList.id})
                    {
                        let lastIndex = self.groceryList.endIndex
                        self.groceryList.insert(groceryList, at: lastIndex)
                    }
                    else
                    {
                        //update the item if found
                        if let row = self.groceryList.firstIndex(where: {$0.id == groceryList.id})
                        {
                            self.groceryList[row] = groceryList
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
    
    
    
