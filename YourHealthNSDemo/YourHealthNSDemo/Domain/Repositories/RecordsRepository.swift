//
//  RecordsRepository.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

protocol RecordsRepository {
    func fetchRecords() async throws -> [PatientRecord]
}
