-- inner join(가장 많이 사용하는 join)
-- 두 테이블 사이에 지정된 조건에 맞는 레코드만 반환. on 조건을 통해 교집합 찾기
-- 글 중에 글쓴이가 있는 사람을 고르고, 글에 글쓴이 데이터를 합한 테이블 생성
select * from post inner join author on author.id=post.author_id;
-- 유저 중에 글을 쓴 사람을 고르고, 유저에 게시글 데이터를 합한 테이블 생성   --> 관점의 차이. 결과 값은 똑같다
select * from author inner join post on author.id=post.author_id;

select * from author a /*as a*/inner join post p on a.id = p.author_id;

-- 글쓴이가 있는 글 목록과 글쓴이의 이메일을 출력하시오. 
select p.id, p.title, p.contents, a.email from post p inner join author a on p.author_id = a.id; -- 익명 글은 빼고 출력

-- 모든 글 목록을 출력하고, 만약에 글쓴이가 있다면 이메일을 출력
select p.id, p.title, p.contents, a.email from post p 
left outer/*outer 생략 가능(보통 안쓰고 함)*/join author a on p.author_id = a.id;-- 나오고 싶게 하는 테이블을 왼쪽에 놓기

-- join된 상황에서의 where 조건 : on 뒤에 where 조건이 나옴
-- 1) 글쓴이가 있는 글 중에 글의 title과 저자의 email 출력, 저자의 나이는 25세 이상
select p.title, a.email from post p inner join author a on p.author_id = a.id where age >= 25;
-- 2) 모든 글 목록 중에 글의 title과 저자가 있다면 email을 출력, 2024-05-01 이후에 만들어진 글만 출력
select p.title, ifnull(a.email, '익명') from post p left join author a on p.author_id = a.id 
where p.title is not null and p.created_time >= '2024-05-01';

-- 조건에 맞는 도서와 저자 리스트 출력
-- https://school.programmers.co.kr/learn/courses/30/lessons/144854
SELECT B.BOOK_ID, A.AUTHOR_NAME, DATE_FORMAT(B.PUBLISHED_DATE, '%Y-%m-%d') as PUBLISHED_DATE FROM AUTHOR AS A JOIN 
BOOK AS B ON B.AUTHOR_ID = A.AUTHOR_ID WHERE B.CATEGORY = '경제' ORDER BY B.PUBLISHED_DATE;

-- union : 중복제외한 두 테이블의 select를 결합
-- 컬럼의 개수와 타입이 같아야함에 유의
-- union all : 중복 포함
select 컬럼1, 컬럼2 from 테이블1 union select 컬럼1, 컬럼2 from 테이블2;
-- author 테이블의 name, email 그리고 post 테이블의 title, contents union
select name, email from author union select title, contents from post;

select count(*) from post where author_id = 1; -- author_id = 1인 post의 row개수 조회

-- 서브쿼리 : select문 안에 또다른 select문을 서브쿼리라 한다.
-- select절 안에 서브쿼리
-- author email과 해당 author가 쓴 글의 개수를 출력
select email, (select count(*) from post p where p.author_id = a.id) as count from author a;
-- from절 안에 서브쿼리
select a.name from(select * from author) as a;  --성능이 떨어지긴 하지만 반드시 써야되는 상황이 올 수 있다(이 케이스는 어거지)
-- where절 안에 서브쿼리
select a.* from author a inner join post p on a.id = p.author_id;
select * from author where id in (select author_id from post);  -- 대체할 수 있으면 join이 낫다

-- 없어진 기록 찾기 문제 : join으로 풀 수 있는 문제, subquery로도 풀어보면 좋을 것
/*JOIN 풀이*/ SELECT O.ANIMAL_ID, O.NAME FROM ANIMAL_OUTS O LEFT JOIN ANIMAL_INS I ON O.ANIMAL_ID = I.ANIMAL_ID 
WHERE I.ANIMAL_ID IS NULL ORDER BY O.ANIMAL_ID;
/*SUBQUERY 풀이*/ SELECT O.ANIMAL_ID, O.NAME FROM ANIMAL_OUTS O WHERE 
ANIMAL_ID NOT IN(SELECT ANIMAL_ID FROM ANIMAL_INS) ORDER BY ANIMAL_ID;

-- 집계함수 
select count(*) from author;
select sum(price) from post;
select round(avg(price), 2)from post;  -- ROUND는 소수점 몇자리에서 반올림 할 지

-- group by와 집계함수
select title from post group by author_id; -- 불가능한 경우(출력은 됨)
select author_id from post group by author_id;
select author_id, count(*) from post group by author_id;
select author_id, count(*), sum(price), round(avg(price), 0), min(price),
max(price) from post group by author_id;

select a.id, if(p.id is null, 0, count(*)) from author a left join post p on a.id = p.author_id group by a.id;
-- 저자 email, 해당 저자가 작성한 글 수를 출력

-- where와 group by
-- 연도별 post 글 출력, 연도가 null인 데이터 제외
select 연도, count(*) from where xxxx group by 연도;
select date_format(created_time, '%Y') /*as year*/, count(*) from post 
where created_time is not null
group by /*year*/created_time;

-- 자동차 종류 별 특정 옵션이 포함된 자동차 수 구하기
-- https://school.programmers.co.kr/learn/courses/30/lessons/151137
SELECT CAR_TYPE, COUNT(*) AS COUNT FROM CAR_RENTAL_COMPANY_CAR 
WHERE OPTIONS LIKE '%시트%'
GROUP BY CAR_TYPE
ORDER BY CAR_TYPE;
-- 나의 코드 위쪽
SELECT CAR_TYPE, COUNT(*) AS COUNT FROM CAR_RENTAL_COMPANY_CAR 
WHERE OPTIONS LIKE '%열선시트%' OR OPTIONS LIKE '%가죽시트%' OR OPTIONS LIKE '%통풍시트%'
GROUP BY CAR_TYPE
ORDER BY CAR_TYPE;

-- 입양 시각 구하기(1)
SELECT cast(DATE_FORMAT(DATETIME,'%H')as unsigned) AS HOUR, COUNT(*) AS COUNT FROM ANIMAL_OUTS
WHERE DATE_FORMAT(DATETIME, '%H:%i') BETWEEN '09:00' AND '19:59'
GROUP BY HOUR ORDER BY HOUR;

-- HAVING : GROUP BY를 통해 나온 통계에 대한 조건
select author_id a, count(*) from post group by a;
-- 글을 2개 이상 쓴 사람에 대한 통계 정보
select author_id, count(*) as count from post group by author_id having count>=2;
-- (실습) 포스팅 price가 2000원 이상인 글을 대상으로, 작성자별로 몇건인지와 평균price를 구하되,
-- 평균 price가 3000원 이상인 데이터를 대상으로만 통계 출력
select author_id, avg(price) as avg from post 
where price >= 2000 
group by author_id having avg >= 3000;
-- 동명 동물 수 찾기
SELECT NAME, COUNT(*) AS COUNT FROM ANIMAL_INS 
WHERE NAME IS NOT NULL
GROUP BY NAME HAVING COUNT >= 2 ORDER BY NAME;
-- (실습)2건 이상의 글을 쓴 사람의 글의 수와 email을 구할건데, 나이는 25세 이상인 사람만 통계에 사용하고,
-- 가장 나이 많은 사람 1명의 통계만 출력하시오
select a.email, count(a.id) as count from author a join post p on a.id = p.author_id
where age >= 25
group by a.id having count >= 2 order by max(a.age) desc limit 1;

-- 다중열 group by
select author_id, title, count(*) from post group by author_id, title;

-- 재구매가 일어난 상품과 회원 리스트 구하기
SELECT USER_ID, PRODUCT_ID FROM ONLINE_SALE GROUP BY USER_ID, PRODUCT_ID 
HAVING COUNT(*) >= 2 ORDER BY USER_ID, PRODUCT_ID DESC;