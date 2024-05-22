-- index 생성문
create index 인덱스명 on 테이블명(컬럼명);

-- index 조회
show index from 테이블명;

-- index 삭제
alter table 테이블명 drop index 인덱스명;

-- 테이블 생성
CREATE TABLE author (
   id bigint(20) NOT NULL AUTO_INCREMENT,
   email varchar(255) DEFAULT NULL,
   PRIMARY KEY (id)
 );

 -- 대량 데이터 생성 프로시저 생성
 DELIMITER //
CREATE PROCEDURE insert_authors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE email VARCHAR(100);
    DECLARE batch_size INT DEFAULT 10000; -- 한 번에 삽입할 행 수
    DECLARE max_iterations INT DEFAULT 100; -- 총 반복 횟수 (100000000 / batch_size)
    DECLARE iteration INT DEFAULT 1;
    WHILE iteration <= max_iterations DO
        START TRANSACTION;
        WHILE i <= iteration * batch_size DO
            SET email = CONCAT('name', i, '@naver.com');
            INSERT INTO author (email) VALUES (email);
            SET i = i + 1;
        END WHILE;
        COMMIT;
        SET iteration = iteration + 1;
        DO SLEEP(0.1); -- 각 트랜잭션 후 0.1초 지연
    END WHILE;
END //
DELIMITER ;
-- 데이터 생성 후 확인
call insert_authors();
select count() from author;

-- 인덱스
create index email_index on author(email);
select from author where email = 'name99999@naver.com'; --인덱스 생성 전 후 속도 차이 비교

