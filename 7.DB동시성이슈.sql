-- dirty read 실습
-- 워크벤치에서 auto_commit 해제 후 update 실행 -> commit이 안된 상태
-- 터미널을 열어서 select 했을 때 위의 변경 사항이 변경됐는 지 확인
변경 x

-- phantom read 동시성 이슈 실습
-- 워크벤치에서 시간을 두고 2번의 select가 이뤄지고, 터미널 중간에 insert 실행
-- -> 2번의 select 결과값이 동일한지 확인

start transaction;
select count() from author;
do sleep(15);
select count() from author;
commit;

-- 터미널에서 아래 insert문 실행
insert into author(name, email) values('kim', 'kim@naver.com');


-- lost update 이슈를 해결하기 위한 공유락(shared lock)
start transaction;
select post_count from author where id = 1 lock in share mode;
do sleep(15);
select post_count from author where id = 1 lock in share mode;
commit;

-- 터미널에서 실행
select post_count from author where id = 1 lock in share mode; -- 얘는 바로 입력됨
update author set post_count = 0 where id = 1; -- 얘는 위의 트랜잭션 끝나고 입력됨

-- 배타적 잠금(exclusive lock) : select for update
-- select 부터 lock
start transaction;
select post_count from author where id = 1 for update;
do sleep(15);
select post_count from author where id = 1 for update;
commit;

-- 터미널에서 실행
select post_count from author where id = 1 for update; -- select update 둘 다 트랜잭션 기다림
update author set post_count = 0 where id = 1;