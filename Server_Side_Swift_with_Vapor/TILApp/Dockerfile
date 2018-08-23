# 1 : Swift 4.1 image를 사용
FROM swift:4.1

# 2 : 작업 디렉토리 /package로 설정
WORKDIR /package
# 3 : 현재 디렉토리의 내용을 컨테이너 /package로 복사
COPY . ./
# 4 : dependencies를 연결하고, 프로젝트의 build artifacts 정리
RUN swift package resolve
RUN swift package clean
#5 : default command를 swift test로 설정한다. Dockerfile을 실행할 때 Docker가 실행하는 명령이다.
CMD ["swift", "test"]
