//
//  Guid.swift
//  WindReadBook
//
//  Created by 张旭 on 16/1/11.
//  Copyright © 2016年 张旭. All rights reserved.
//

import Foundation

struct Guid{
	static private let identifier = NSUUID().UUIDString
	static private let base64TailBuffer = "="
	static private func compressIdentifier() -> String {
		let tempUuid = NSUUID(UUIDString: identifier)
		var tempUuidBytes: UInt8 = 0
		tempUuid!.getUUIDBytes(&tempUuidBytes)
		let data = NSData(bytes: &tempUuidBytes, length: 16)
		let base64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
		return base64.stringByReplacingOccurrencesOfString(base64TailBuffer, withString: "")
	}
	static private func rehydrate(shortenedIdentifier: String?) -> String? {
		// Expand an identifier out of a CBAdvertisementDataLocalNameKey or service characteristic.
		if shortenedIdentifier == nil {
			return nil
		}
		else {
			// Rehydrate the shortenedIdentifier
			let shortenedIdentifierWithDoubleEquals = shortenedIdentifier! + base64TailBuffer + base64TailBuffer
			let data = NSData(base64EncodedString: shortenedIdentifierWithDoubleEquals, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
			let tempUuid = NSUUID(UUIDBytes: UnsafePointer<UInt8>(data!.bytes))
			return tempUuid.UUIDString
		}
	}
	static func getGuid()->String{
		let testCompress = compressIdentifier()
		let testRehydrate = rehydrate(testCompress)
		return testRehydrate!
	}
}