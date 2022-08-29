import Foundation
import CloudKit
import UIKit

var containerIdentifier = "iCloud.vanzylarno.MyCookBook"
var container = CKContainer(identifier: containerIdentifier)
var database = container.privateCloudDatabase


