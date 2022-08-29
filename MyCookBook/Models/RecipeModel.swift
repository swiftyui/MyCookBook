import Foundation
import CloudKit
import UIKit

class RecipeModel: ObservableObject {
    
    ///Variables
    @Published var recipes: [Recipe] = []

    typealias CompletionHandler = (_ success: Bool) -> Void
    
    /// Saving the recipe to iCloud
    func saveRecipe(recipe: Recipe, completion: @escaping (Bool) -> ()) throws{
        
        /// Get the Food Items in an Array
        let encoder = JSONEncoder()
        var encodedArray: Data
        do { encodedArray = try encoder.encode(recipe.items) }
        catch { throw error }
        
        /// Get the steps in an Array
        var encodedSteps: Data
        do { encodedSteps = try encoder.encode(recipe.steps)}
        catch{ throw error }
        
        /// Get the Recipes Image
        var asset: CKAsset
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(recipe.image.description),
              let data = recipe.image.jpegData(compressionQuality: 1.0) else { return }
        do { try data.write(to: url); asset = CKAsset(fileURL: url)}
        catch { throw error }
        
        /// Create the new CKRecord
        let newRecord = CKRecord(recordType: "Recipe")
        newRecord.setValuesForKeys([
            "id": recipe.id,
            "name": recipe.name,
            "items": encodedArray,
            "image": asset,
            "recipeType": recipe.recipeType,
            "steps": encodedSteps
        ])
    
        database.save(newRecord, completionHandler: { record, error in
            do { sleep(4) }
            completion(true)
        })
    }
    
    /// Load the Recipes stored
    func loadRecipes(completion: @escaping (Bool) -> ()) {
        
        /// Create the Query to execute
        let query = CKQuery(recordType: "Recipe", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        /// Create the database Operation
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 10
        database.add(operation)
        
        /// Iteratively call until all is loaded
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
                    var recipe: Recipe = Recipe(id: "", name: "", items: [], addToList: false, recipeType: "", steps: [])

                    recipe.id = record["id"] as! String
                    recipe.name = record["name"] as! String
                    recipe.recipeType = record["recipeType"] as! String
                    

                    if(record["items"] != nil)
                    {
                        let data: Data = record["items"] as! Data
                        recipe.items = try! decorder.decode([FoodItem].self, from: data)
                    }
                    
                    if(record["steps"] != nil)
                    {
                        let data: Data = record["steps"] as! Data
                        recipe.steps = try! decorder.decode([CookingSteps].self, from: data)
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

                    recipe.image = uiImage


                    //only add if it doesn't exist already
                    if !self.recipes.contains(where: {$0.id == recipe.id})
                    {
                        let lastIndex = self.recipes.endIndex
                        self.recipes.insert(recipe, at: lastIndex)
                    }
                    else
                    {
                        //update the item if found
                        if let row = self.recipes.firstIndex(where: {$0.id == recipe.id})
                        {
                            self.recipes[row] = recipe
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateRecipe(recipe: Recipe, completion: @escaping (Bool) -> ()) {
        /// Create a filter predicate
        let filter = recipe.id
        let predicate = NSPredicate(format: "id == %@", filter)
        
        /// Create the Query
        let query = CKQuery(recordType: "Recipe", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        /// Create the operation
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["id", "name", "items", "image", "recipeType", "steps"]
        database.add(operation)
        
        // Iteratively call until all blocks are loaded
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
        
        /// Matched Records
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):

                ///update the record
                let encoder = JSONEncoder()
                let encodedArray = try! encoder.encode(recipe.items)
                let encodedSteps = try! encoder.encode(recipe.steps)

                ///get the image as an asset
                guard
                    let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(recipe.image.description),
                    let data = recipe.image.jpegData(compressionQuality: 1.0) else { return }

                do{
                    try data.write(to: url)
                } catch let error {
                    print(error.localizedDescription)
                }
                let asset = CKAsset(fileURL: url)

                record.setValuesForKeys([
                    "id": recipe.id,
                    "name": recipe.name,
                    "items": encodedArray,
                    "image": asset,
                    "recipeType": recipe.recipeType,
                    "steps": encodedSteps
                ])

                database.save(record, completionHandler: { record, error in
                    completion(true)
                })

            case.failure(let error):
                print(error)
            }
        }
    }
    
    /// Delete the Recipe
    func deleteRecipe(recipe: Recipe, completion: @escaping (Bool) -> ()) {

        ///create a filter Predicate
        let filter = recipe.id
        let predicate = NSPredicate(format: "id == %@", filter)

        ///create the Query
        let query = CKQuery(recordType: "Recipe", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        ///create the Operation
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["id", "name", "items", "image", "recipeType", "steps"]
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

        ///record match
        operation.recordMatchedBlock = { recordID, result in
                database.delete(withRecordID: recordID, completionHandler: { record, error in
                    completion(true)
                })
        }
    }
}
