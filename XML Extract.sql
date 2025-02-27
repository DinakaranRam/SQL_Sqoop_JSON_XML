SELECT INCAB_MSG_HDR_ID ID,
  ODS.NUMBER_VALIDATER(TO_CHAR(TM) ,0,'4,0') OFFSET_TIME_SEC,
TO_CHAR(:INC_DTTM +(TM/86400),'MM/DD/YYYY HH12:MI:SS AM') ABS_TIME,
SPEED,
  FOLLOW_TIME,
  CASE
    WHEN TM < 0
    THEN '-'
  END
  || TRUNC(ABS(TM)/60)
  ||':'
  || LPAD(MOD(ABS(TM),60),2,0)OFFSET_TIME_MIN
FROM
  (SELECT B.INCAB_MSG_HDR_ID ,
    MOD(X.SEQ_NUM - EXTRACTVALUE((MSG_TXT),'/InboundMessageWrapper/OrionCriticalEvent/OrionCriticalEvent/Sample/TimeOffset'),
    EXTRACTVALUE((MSG_TXT),'/InboundMessageWrapper/OrionCriticalEvent/OrionCriticalEvent/Sample/TimeOffset')) TM,
    Y.SPEED SPEED,
    X.FOLLOWINGTIME FOLLOW_TIME
  FROM
    (SELECT INCAB_MSG_HDR_ID,
      xmltype(
      CASE
        WHEN MSG_TXT LIKE '%xmlns="http://kepler..com"%'
        THEN REPLACE(MSG_TXT,'xmlns="http://kepler..com"','')
        WHEN MSG_TXT LIKE '%xmlns="http://telematics-hub.truckingcompany.com"%'
        THEN REPLACE(MSG_TXT,'xmlns="http://telematics-hub.truckingcompany.com"','')
      END) AS "MSG_TXT"
    FROM
      (SELECT E.INCAB_MSG_HDR_ID,
        dbms_xmlgen.convert(XMLAGG(XMLELEMENT(E, E.MSG_TXT
        ||'').EXTRACT('//text()')
      ORDER BY MSG_DTL_SEQ_NUM).GETCLOBVAL(),1) AS "MSG_TXT"
      FROM ODS.X2_SMS_INCAB_MSG_DTL E
      INNER JOIN ODS.X2_SMS_INCAB_MSG_HDR H
      ON H.INCAB_MSG_HDR_ID     = E.INCAB_MSG_HDR_ID
      WHERE E.INCAB_MSG_HDR_ID IN (:MSG_ID)
      AND H.MSG_TYP_CD          ='OrionCriticalEvent'
      GROUP BY E.INCAB_MSG_HDR_ID
      ) B
    ) B ,
    XMLTABLE ( '/InboundMessageWrapper/OrionCriticalEvent/OrionCriticalEvent/Sample/FollowingTimeList/FollowingTime' PASSING B.MSG_TXT columns FOLLOWINGTIME VARCHAR2(6) PATH '.', SEQ_NUM FOR ORDINALITY ) X ,
    XMLTABLE ( '/InboundMessageWrapper/OrionCriticalEvent/OrionCriticalEvent/Sample/SpeedList/Speed' PASSING B.MSG_TXT COLUMNS SPEED                         VARCHAR2(6) PATH '.', SEQ_NUM FOR ORDINALITY ) Y
  WHERE X.SEQ_NUM = Y.SEQ_NUM
  )
WHERE TM IS NOT NULL

