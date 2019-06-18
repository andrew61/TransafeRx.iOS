//
//  DBManager.swift
//  TransafeRx
//
//  Created by Andrew West on 11/16/18.
//  Copyright © 2018 Tachl. All rights reserved.
//

import Foundation
import GRDB

open class DBManager{

    var databasePath = Bundle.main.path(forResource: "TransafeRxDB", ofType: "sql")
    
    static let sharedManager = DBManager()

    // MARK: - Initialization
    public init(){
        do{
            try copyDatabase()
            try createBloodPressureTable()
            try createBloodGlucoseTable()
        }catch{
            print(error)
        }
    }
    
    func copyDatabase() throws{
        let fileManager = FileManager.default
        let dbPath = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("TransafeRxDB.sql")
            .path
        if !fileManager.fileExists(atPath: dbPath) {
            if let dbResourcePath = Bundle.main.path(forResource: "TransafeRxDB", ofType: "sql"){
                try fileManager.copyItem(atPath: dbResourcePath, toPath: dbPath)
            }
        }
        databasePath = dbPath
    }
    
    // MARK: -- Tables
    func createBloodPressureTable() throws{
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            try dbQueue.write { db in
                try db.execute("""
        CREATE TABLE IF NOT EXISTS BloodPressureMeasurements (
            BloodPressureId INTEGER PRIMARY KEY AUTOINCREMENT,
            Systolic INT NOT NULL,
            Diastolic INT NOT NULL,
            Pulse INT NULL,
            ReadingDate TEXT NOT NULL,
            Model TEXT NULL)
        """)
            }
        }
    }
    
    func createBloodGlucoseTable() throws{
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            try dbQueue.write { db in
                try db.execute("""
        CREATE TABLE IF NOT EXISTS BloodGlucoseMeasurements (
            BloodGlucoseId INTEGER PRIMARY KEY AUTOINCREMENT,
            GlucoseLevel INT NOT NULL,
            ReadingDate TEXT NOT NULL,
            Model TEXT NULL)
        """)
            }
        }
    }
    
    // MARK: -- BloodPressure
    func insertBloodPressure(_ bp: BloodPressureMeasurement) throws{
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            try dbQueue.write { db in
                try db.execute(
                    "INSERT INTO BloodPressureMeasurements (Systolic, Diastolic, Pulse, ReadingDate, Model) VALUES (?, ?, ?, ?, ?)",
                    arguments: [bp.Systolic, bp.Diastolic, bp.Pulse, bp.ReadingDate?.dateTimeUTC, bp.Model])
            }
        }
    }
    
    func deleteBloodPressure(_ bp: BloodPressureMeasurement) throws{
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            try dbQueue.write { db in
                try db.execute(
                    "DELETE FROM BloodPressureMeasurements WHERE BloodPressureId = ?",
                    arguments: [bp.BloodPressureId])
            }
        }
    }
    
    func getBloodPressures() throws -> [BloodPressureMeasurement]{
        var bpMeasurements = [BloodPressureMeasurement]()
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            let measurements = try dbQueue.read { db in
                try BloodPressureDB.fetchAll(db, "SELECT * FROM BloodPressureMeasurements")
            }
            if !measurements.isEmpty{
                for bp in measurements{
                    bpMeasurements.append(BloodPressureMeasurement(bp: bp))
                }
            }
        }
        
        return bpMeasurements
    }
    
    func transmitBloodPressures(){
        do{
            let measurements = try getBloodPressures()
            for measurement in measurements{
                ApiManager.sharedManager.saveBloodPressure(measurement) { (error) in
                    if error == nil{
                        do{
                            try self.deleteBloodPressure(measurement)
                        }catch{
                            print(error)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: -- BloodGlucose
    func insertBloodGlucose(_ bg: BloodGlucoseMeasurement) throws{
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            try dbQueue.write { db in
                try db.execute(
                    "INSERT INTO BloodGlucoseMeasurements (GlucoseLevel, ReadingDate, Model) VALUES (?, ?, ?)",
                    arguments: [bg.GlucoseLevel, bg.ReadingDate?.dateTimeUTC, bg.Model])
            }
        }
    }
    
    func deleteBloodGlucose(_ bg: BloodGlucoseMeasurement) throws{
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            try dbQueue.write { db in
                try db.execute(
                    "DELETE FROM BloodGlucoseMeasurements WHERE BloodGlucoseId = ?",
                    arguments: [bg.BloodGlucoseId])
            }
        }
    }
    
    func getBloodGlucoses() throws -> [BloodGlucoseMeasurement]{
        var bgMeasurements = [BloodGlucoseMeasurement]()
        if databasePath != nil{
            let dbQueue = try DatabaseQueue(path: databasePath!)
            let measurements = try dbQueue.read { db in
                try BloodGlucoseDB.fetchAll(db, "SELECT * FROM BloodGlucoseMeasurements")
            }
            if !measurements.isEmpty{
                for bg in measurements{
                    bgMeasurements.append(BloodGlucoseMeasurement(bg: bg))
                }
            }
        }
        
        return bgMeasurements
    }
    
    func transmitBloodGlucoses(){
        do{
            let measurements = try getBloodGlucoses()
            for measurement in measurements{
                ApiManager.sharedManager.saveBloodGlucose(measurement) { (error) in
                    if error == nil{
                        do{
                            try self.deleteBloodGlucose(measurement)
                        }catch{
                            print(error)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
    }
}
