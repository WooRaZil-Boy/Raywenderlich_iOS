import Vapor
import Imperial
import Authentication

struct ImperialController: RouteCollection {
    func boot(router: Router) throws {
        //RouteCollection은 boot(router:)를 반드시 구현해야 한다.
        guard let callbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            //환경 변수에서 콜백 URL 을 가져온다. Google 콘솔에서 설정한 URL이다.
            fatalError("Callback URL not set")
        }
        
        try router.oAuth( //라우터에 Imperial의 Google OAuth 라우터를 등록한다
            from: Google.self, //Google handler
            authenticate: "login-google", // /login-google 경로를 OAuth 를 트리거 하는 경로로 설정한다.
            //애플리케이션 사용자가 Google로 로그인 할 수 있도록 사용하는 경로이다.
            callback: callbackURL, //call back URL 을 설정해 준다.
            scope: ["profile", "email"], //사용자 생성 시에 필요한 정보를 Google에 요청한다(프로필과 이메일).
            completion: processGoogleLogin) //완료 시 호출할 클로저
    }
    
    func processGoogleLogin(request: Request, token: String) throws -> Future<ResponseEncodable> {
        //Google 로그인을 처리하는 방법을 정의한다.
        //Imperial은 Google 리디렉션을 처리한 후 이 메서드를 최종 콜백으로 사용한다.
        
//        return request.future(request.redirect(to: "/"))
//        //일반 로그인과 동일한 방식으로 사용자를 root로 리디렉션한다.
//        //Imperial에서 사용하는 함수는 Future을 반환해야 하기 때문에 request.future(_:) 를 사용해야 한다.
        
        return try Google
            .getUser(on: request) //사용자 정보를 얻는다
            .flatMap(to: ResponseEncodable.self) { userInfo in
                
                return User
                    .query(on: request)
                    .filter(\.username == userInfo.email) //username과 메일이 동일한 객체를 찾는다.
                    .first()
                    .flatMap(to: ResponseEncodable.self) { foundUser in
                        
                        guard let existingUser = foundUser else { //사용자가 존재하지 않는다면
                            let user = User(name: userInfo.name,
                                            username: userInfo.email,
                                            password: "")
                            //Google의 사용자 정보에서 이름과 이메일을 사용해서 새 사용자를 만든다.
                            //Google 계정을 사용하므로 암호가 따로 필요하지 않다(공백).
                            
                            return user
                                .save(on: request) //사용자를 저장한다
                                .map(to: ResponseEncodable.self) { user in //unwrapping
                                    try request.authenticateSession(user)
                                    //request.authenticateSession(_:) 로 생성된 사용자를 세션에 저장하면 웹 사이트에서 액세스할 수 있다.
                                    
                                    return request.redirect(to: "/")
                                    //root로 리디렉션
                                }
                        }
                        
                        try request.authenticateSession(existingUser)
                        //사용자가 이미 있다면 세션에서 사용자를 인증하고
                        
                        return request.future(request.redirect(to: "/"))
                        //root로 리디렉션
                    }
            }
    }
}

struct GoogleUserInfo: Content {
    //Google API의 데이터를 디코딩할 유형
    let email: String
    let name: String
    //Imperial oAuth 함수의 scope에서 받아오는 변수들
}

extension Google { //Imperial의 Google 서비스를 extension
    static func getUser(on request: Request) throws -> Future<GoogleUserInfo> {
        //Google API에서 사용자의 세부 정보를 가져온다.
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(token: request.accessToken())
        //인증 헤더에 OAuth 토큰을 추가하여 request의 헤더를 설정한다.
        
        let googleAPIURL = "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
        //request URL을 설정한다. 사용자의 정보를 얻기위한 Google의 API
        
        return try request
            .client() //request.client() 를 사용해 request를 보낼 클라이언트를 만든다.
            .get(googleAPIURL, headers: headers) //get() 은 제공된 URL에 HTTP GET request를 보낸다.
            .map(to: GoogleUserInfo.self) { response in //unwrapping
                guard response.http.status == .ok else { //response status가 200 OK 인지 확인
                    if response.http.status == .unauthorized { //401 Unauthorized 이면
                        throw Abort.redirect(to: "/login-google") //로그인 페이지로 돌아가고
                    } else { //이 외의 오류라면
                        throw Abort(.internalServerError) //오류 반환
                    }
                }
                
                return try response.content
                    .syncDecode(GoogleUserInfo.self)
                //response에서 GoogleUserInfo로 데이터를 디코딩하고 결과를 반환한다.
            }
    }
}



//OAuth 2.0
//OAuth 2.0는 서드 파트 응용 프로그램이 자원에 액세스할 수 있게 해주는 인증 프레임워크이다.
//Google 계정으로 웹 사이트에 로그인 할 때마다 OAuth를 사용한다.
//응용 프로그램이 메일과 같은 사용자의 Google 데이터에 액세스할 수 있도록 권한을 부여한다.
//애플리케이션 액세스를 허용하면, Google은 애플리케이션에 토큰을 제공한다.
//앱은 이 토큰을 사용하여 Google API에 대한 request를 인증한다.




//Imperial
//Imperial은 OAuth 시스템과 상호작용하고 토큰을 얻는 작업을 간단히 할 수 있는 패키지이다.

//Setting up your application with Google
//OAuth 생성시 Authorized redirect URIs는 사용자가 응용 프로그램에서 데이터에 액세스하도록 허용하면 Google이 다시 리디렉션하는 URL이다.
//http://localhost:8080/oauth/google (Local)
//https://<YOUR_VAPOR_CLOUD_URL>/oauth/google (Vapor Cloud)
//이런 식으로 설정해 주면 된다.

//Setting up the integration
//Imperial이 제대로 작동하려면 Google console에서 확인할 수 있는 client ID client secret를 설정해 줘야 한다.
//환경 변수를 사용해 Imperial에 설정한다. Xcode에서는 실행 시의 Scheme를 편집해 설정해 줄 수 있다.
//빌드 버튼 옆의 Scheme 를 눌러 Edit scheme를 선택한다.
//Run의 Arguments 탭에서 Environment Variables 부분에 다음 세 가지 key-value를 추가해 준다.
// • GOOGLE_CALLBACK_URL
// • GOOGLE_CLIENT_ID
// • GOOGLE_CLIENT_SECRET




//Deploying to Vapor Cloud p.369
//Vapor Cloud에 배포하기 전에 OAuth의 client ID, secret, callback URL 를 제공해야 한다.
//vapor cloud config modify config set --env=production \
//    GOOGLE_CALLBACK_URL=https://<YOUR_VAPOR_CLOUD_URL>/oauth/google
//vapor cloud config modify config set --env=production \
//GOOGLE_CLIENT_ID=<YOUR_CLIENT_ID>
//vapor cloud config modify config set --env=production \
//GOOGLE_CLIENT_SECRET=<YOUR_CLIENT_SECRET>
//터미널에서 배포 전에 이런 식으로 지정해 줘야 한다.
//이렇게 해서 git이나 Local에 정보를 저장하지 않고도 Vapor Cloud에 전달해 줄 수 있다.
