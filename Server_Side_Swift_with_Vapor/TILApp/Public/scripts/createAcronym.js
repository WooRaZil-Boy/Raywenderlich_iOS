$.ajax({
    url: "/api/categories/",
    type: "GET",
    contentType: "application/json; charset=utf-8"
    //페이지 로드 시, /api/categories/에 GET request를 보낸다. TIL 앱에서 모든 카테고리를 가져온다.
}).then(function (response) {
    var dataToReturn = [];

    for (var i=0; i < response.length; i++) {
        //가져온 카테고리를 loop를 돈다.
        var tagToTransform = response[i];
        var newTag = {
            id: tagToTransform["name"],
            text: tagToTransform["name"]
        }; //JSON 객체로 변환

        // {
        //     "id": <name of the category>,
        //     "text": <name of the category>
        // }
        //위와 같은 형태의 JSON이 된다.

        dataToReturn.push(newTag); //dataToReturn에 추가한다.
    }

    $("#categories").select2({ //id가 categories인 HTML 요소를 가져와 select2 호출
        //createAcronym에서 form의 id가 categories이므로 <select>에서 select2가 활성화된다.
        placeholder: "Select Categories for the Acronym", //placeholder 텍스트 설정
        tags: true, //태그를 활성화하면 사용자는 입력에 존재하지 않는 새로운 카테고리를 동적으로 생성할 수 있다.
        tokenSeparators: [','], //구분 기호를 ','로 설정.
        data: dataToReturn //사용자가 선택할 수 있는 select의 option 들을, dataToReturn의 카테고리들로 설정한다. 
    });
});
