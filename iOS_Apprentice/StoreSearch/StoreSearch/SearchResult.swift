//
//  SearchResult.swift
//  StoreSearch
//
//  Created by IndieCF on 2018. 2. 27..
//  Copyright © 2018년 근성가이. All rights reserved.
//

class ResultArray: Codable { //JSON parser Object
    //JSON parser
    //iOS 11 이전에는 JSON 파싱하려면 다른 프레임워크나, iOS의 JSON parser를 이용해 수동으로 해 줘야 했다.
    //iOS 11에선 Codable을 사용할 수 있다. //Codable를 준수하는 JSON 데이터 객체를 설정하면 된다.
    //파싱할 데이터 구조체나 클래스에서 JSON results에 맞춰 설정해 주면 된다.
    var resultCount = 0
    var results = [SearchResult]()
    //해당 앱에서 JSON reusults가 결과 카운터와 결과 배열로 되어 있으므로 거기에 맞춰서 프로퍼티를 생성해 준다.
} //SearchResult와 연관이 있고, SearchResult와 연동되는 경우 밖에 쓰이지 않으므로 같은 파일에 넣었다.

class SearchResult: Codable { //JSON parser로 실제로 사용할(필요한) 데이터를 저장하는 클래스
    //iOS 11 이전에는 JSON 파싱하려면 다른 프레임워크나, iOS의 JSON parser를 이용해 수동으로 해 줘야 했다.
    //iOS 11에선 Codable을 사용할 수 있다. //Codable를 준수하는 JSON 데이터 객체를 설정하면 된다.
    //파싱할 데이터 구조체나 클래스에서 JSON results에 맞춰 설정해 주면 된다.
    //모든 key를 저장할 필요 없다. 사용할(필요한) key만 프로퍼티로 설정하고 Codable를 구현하면, JSONDecoder으로 해당 부분만 파싱할 수 있다.
    //프로퍼티 명을 JSON key와 일치하지 않아도 파싱을 할 수는 있지만(CodingKey를 지정), 되도록이면 맞춰주는 것이 좋다.
    //kind마다 다른 JSON key 값을 가지고 있다. //이를 고려해서 프러퍼티를 만들어야 한다(옵셔널).
    //예를 들어 song에는 trackName이지만, audio-book에서는 collectionName
    var kind: String? //종류, 분류
    var artistName = "" //아티스트 이름
    var trackName: String? //트랙 이름
    var trackPrice: Double? //가격
    var currency = "" //통화(달러, 파운드, 유로..)
    
    var imageSmall = "" //artworkUrl60 = "" //60픽셀 이미지 URL
    var imageLarge = "" //artworkUrl100 = "" //100픽셀 이미지 URL
    
    var trackViewUrl:String?
    var collectionName:String?
    var collectionViewUrl:String?
    var collectionPrice:Double?
    var itemPrice:Double?
    var itemGenre:String?
    var bookGenre:[String]?
    
    enum CodingKeys: String, CodingKey { //프로퍼티 이름과 JSON results의 key가 일치하지 않을 때 연결시켜 준다.
        //CodingKeys로 인코딩, 디코딩에 사용할 키를 지정한다. //CodingKeys를 사용하면 모든 속성을 열거해 줘야 한다.
        case imageSmall = "artworkUrl60" //프로퍼티와 JSON key가 다른 경우
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency //프로퍼티와 JSON key가 동일한 경우
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    //kind에 따라 JSON key가 다르다. 이를 통일 시켜 주기 위한 computed properties
    var name: String {
        return trackName ?? collectionName ?? "" //nil-coalescing operator
        //trackName를 확인해 값이 있으면 trackName 반환
        //trackName가 nil이면 collectionName를 확인해 값이 있으면 collectionName, 없으면 "" 반환
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? "" //nil-coalescing operator
    }
    
    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0 //nil-coalescing operator
    }
    
    var genre: String {
        if let genre = itemGenre { //전자책이 아닌 경우, 해당 항목의 장르 반환
            return genre
        } else if let genres = bookGenre { //전자책인 경우, 쉼표로 구분된 모든 장르 값을 결합해 반환
            return genres.joined(separator: ", ") //배열의 요소를 ,로 구분해 하나의 문자열로 만든다.
        }
        
        return ""
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook" //audiobook인 경우 kind가 nil인 품목들이 있다.
        
        switch kind { //텍스트를 좀 더 이해하기 쉽게 변환 //Swift에서 switch는 가능한 모든 case가 있어야 한다.
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: break
        } //Swift에서는 break를 모든 case에 써 줄 필요 없다. 다른 언어와 달리 하나의 case만 실행하는 것이 기본
        //fallthrough를 써서, 다른 언어의 switch처럼 해당하는 모든 case를 거치도록 할 수 있다.
        
        return "Unknown"
    }
}

//MARK - CustomStringConvertible
extension SearchResult: CustomStringConvertible { //문자열 표현 방법을 지정해 줄 수 있다(print 문).
    //description 프로퍼티를 구현해, 객체나 객체의 내용을 설명하는 문자열을 만들 수 있다.
    var description: String {
        return "Kind: \(kind ?? ""), Name: \(name), Artist Name: \(artistName)\n"
        //kind ?? "" :: 값이 있으면 kind 값, 없으면(nil) "" //nil-coalescing operator
    }
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool { //새로운 연산자 정의
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    //name을 오름차순으로 비교해 Bool 반환
}

