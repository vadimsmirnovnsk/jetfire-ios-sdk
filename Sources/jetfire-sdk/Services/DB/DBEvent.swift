import Foundation

//	CREATE TABLE "events"
//	(
//		"id"           INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
//		"event_type"   INTEGER                           NOT NULL,
//		"custom_event" VARCHAR(255)                      NULL,
//		"event_uuid"   VARCHAR(20)                       NOT NULL,
//		"campaign_id"  INTEGER                           NULL,
//		"feature"      VARCHAR(255)                      NULL,
//		"feature_id"   INTEGER                           NULL,
//		"entity_id"    INTEGER                           NULL,
//		"date"         DATE                                       DEFAULT CURRENT_TIMESTAMP NOT NULL,
//		"timestamp"    DATETIME                                   DEFAULT CURRENT_TIMESTAMP NOT NULL,
//		"data"         TEXT                              NULL
//	);
//
//	event_type – интовый id события из протобафовского EventType
//	custom_event – если тип события кастомный, то тут имя этого кастомного события
//	event_uuid – рандомно сгенерированный UUID
//	feature – текстовое имя фичи
//	campaign_id, feature_id, entity_id – данные из фичеринга, если есть
//	date, timestamp – отдельно поле с датой без времени для удобства и поле с полным таймстемпом события
//	data – поле текстовое, чтобы хранить например, json с дополнительными параметрами

public struct DBEvent: Codable {

	let id: Int?
	let event_type: Int
	let custom_event: String?
	let event_uuid: String
	let campaign_id: Int64?
	let feature: String?
	let feature_id: Int?
	let entity_id: String?
	let date: String
	let timestamp: Date
	let data: Data?

	enum CodingKeys: String, CodingKey {
		case id
		case event_type
		case custom_event
		case event_uuid
		case campaign_id
		case feature
		case feature_id
		case entity_id
		case date
		case timestamp
		case data
	}

}
