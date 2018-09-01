function cookiesConfirmed() { //사용자가 쿠키 메시지에서 확인 링크를 클릭할 때 브라우저에서 호출하는 함수
    $('#cookie-footer').hide();
    //쿠키 메시지를 숨긴다.

    var d = new Date(); //현재 시간
    d.setTime(d.getTime() + (365*24*60*60*1000)); //1년 뒤의 시간
    var expires = "expires="+ d.toUTCString(); //쿠키 만료일
    //기본적으로 쿠키는 브라우저 세션에서 유효하다. 사용자가 브라우저 창이나 탭을 닫으면 브라우저가 쿠키를 삭제한다.
    //날짜를 추가하면 브라우저가 1년동안 쿠키를 유지한다.

    document.cookie = "cookies-accepted=true;" + expires;
    //cookies-accepted라는 쿠키를 페이지에 추가한다.
    //쿠키 동의 메시지를 표시할 지 여부를 결정할 때 이 쿠기가 존재하는지 확인한다.
}
