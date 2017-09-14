-- Load Summary Table
CREATE TABLE Summary(
   CustID INTEGER PRIMARY KEY CHECK (CustID > 0), 
   SFCCode DECIMAL(3, 0) CHECK (SFCCode >= 0), 
   RetF07Dollars INTEGER NOT NULL CHECK (RetF07Dollars >= 0),
   RetF07Trips INTEGER NOT NULL CHECK (RetF07Trips >= 0),
   RetF07Lines INTEGER NOT NULL CHECK (RetF07Lines >= 0),
   RetS07Dollars INTEGER NOT NULL CHECK (RetS07Dollars >= 0),
   RetS07Trips INTEGER NOT NULL CHECK (RetS07Trips >= 0),
   RetS07Lines INTEGER NOT NULL CHECK (RetS07Lines >= 0),
   RetF06Dollars INTEGER NOT NULL CHECK (RetF06Dollars >= 0),
   RetF06Trips INTEGER NOT NULL CHECK (RetF06Trips >= 0),
   RetF06Lines INTEGER NOT NULL CHECK (RetF06Lines >= 0),
   RetS06Dollars INTEGER NOT NULL CHECK (RetS06Dollars >= 0),
   RetS06Trips INTEGER NOT NULL CHECK (RetS06Trips >= 0),
   RetS06Lines INTEGER NOT NULL CHECK (RetS06Lines >= 0),
   RetF05Dollars INTEGER NOT NULL CHECK (RetF05Dollars >= 0),
   RetF05Trips INTEGER NOT NULL CHECK (RetF05Trips >= 0),
   RetF05Lines INTEGER NOT NULL CHECK (RetF05Lines >= 0),
   RetS05Dollars INTEGER NOT NULL CHECK (RetS05Dollars >= 0),
   RetS05Trips INTEGER NOT NULL CHECK (RetS05Trips >= 0),
   RetS05Lines INTEGER NOT NULL CHECK (RetS05Lines >= 0),
   RetF04Dollars INTEGER NOT NULL CHECK (RetF04Dollars >= 0),
   RetF04Trips INTEGER NOT NULL CHECK (RetF04Trips >= 0),
   RetF04Lines INTEGER NOT NULL CHECK (RetF04Lines >= 0),
   RetS04Dollars INTEGER NOT NULL CHECK (RetS04Dollars >= 0),
   RetS04Trips INTEGER NOT NULL CHECK (RetS04Trips >= 0),
   RetS04Lines INTEGER NOT NULL CHECK (RetS04Lines >= 0),
   RetPre04Dollars INTEGER NOT NULL CHECK (RetPre04Dollars >= 0),
   RetPre04Trips INTEGER NOT NULL CHECK (RetPre04Trips >= 0),
   RetPre04Lines INTEGER NOT NULL CHECK (RetPre04Lines >= 0),
   RetPre04Recency SMALLINT NOT NULL CHECK (RetPre04Recency >= 0 AND RetPre04Recency <= 99),
   IntF07GDollars INTEGER NOT NULL CHECK (IntF07GDollars >= 0),
   IntF07NGDollars INTEGER NOT NULL CHECK (IntF07NGDollars >= 0),
   IntF07Orders INTEGER NOT NULL CHECK (IntF07Orders >= 0),
   IntF07Lines INTEGER NOT NULL CHECK (IntF07Lines >= 0),
   IntS07GDollars INTEGER NOT NULL CHECK (IntS07GDollars >= 0),
   IntS07NGDollars INTEGER NOT NULL CHECK (IntS07NGDollars >= 0),
   IntS07Orders INTEGER NOT NULL CHECK (IntS07Orders >= 0),
   IntS07Lines INTEGER NOT NULL CHECK (IntS07Lines >= 0),
   IntF06GDollars INTEGER NOT NULL CHECK (IntF06GDollars >= 0),
   IntF06NGDollars INTEGER NOT NULL CHECK (IntF06NGDollars >= 0),
   IntF06Orders INTEGER NOT NULL CHECK (IntF06Orders >= 0),
   IntF06Lines INTEGER NOT NULL CHECK (IntF06Lines >= 0),
   IntS06GDollars INTEGER NOT NULL CHECK (IntS06GDollars >= 0),
   IntS06NGDollars INTEGER NOT NULL CHECK (IntS06NGDollars >= 0),
   IntS06Orders INTEGER NOT NULL CHECK (IntS06Orders >= 0),
   IntS06Lines INTEGER NOT NULL CHECK (IntS06Lines >= 0),
   IntF05GDollars INTEGER NOT NULL CHECK (IntF05GDollars >= 0),
   IntF05NGDollars INTEGER NOT NULL CHECK (IntF05NGDollars >= 0),
   IntF05Orders INTEGER NOT NULL CHECK (IntF05Orders >= 0),
   IntF05Lines INTEGER NOT NULL CHECK (IntF05Lines >= 0),
   IntS05GDollars INTEGER NOT NULL CHECK (IntS05GDollars >= 0),
   IntS05NGDollars INTEGER NOT NULL CHECK (IntS05NGDollars >= 0),
   IntS05Orders INTEGER NOT NULL CHECK (IntS05Orders >= 0),
   IntS05Lines INTEGER NOT NULL CHECK (IntS05Lines >= 0),
   IntF04GDollars INTEGER NOT NULL CHECK (IntF04GDollars >= 0),
   IntF04NGDollars INTEGER NOT NULL CHECK (IntF04NGDollars >= 0),
   IntF04Orders INTEGER NOT NULL CHECK (IntF04Orders >= 0),
   IntF04Lines INTEGER NOT NULL CHECK (IntF04Lines >= 0),
   IntS04GDollars INTEGER NOT NULL CHECK (IntS04GDollars >= 0),
   IntS04NGDollars INTEGER NOT NULL CHECK (IntS04NGDollars >= 0),
   IntS04Orders INTEGER NOT NULL CHECK (IntS04Orders >= 0),
   IntS04Lines INTEGER NOT NULL CHECK (IntS04Lines >= 0),
   IntPre04GDollars INTEGER NOT NULL CHECK (IntPre04GDollars >= 0),
   IntPre04NGDollars INTEGER NOT NULL CHECK (IntPre04NGDollars >= 0),
   IntPre04Orders INTEGER NOT NULL CHECK (IntPre04Orders >= 0),
   IntPre04Lines INTEGER NOT NULL CHECK (IntPre04Lines >= 0),
   IntPre04Recency SMALLINT NOT NULL CHECK (IntPre04Recency >= 0 AND IntPre04Recency <= 99),
   CatF07GDollars INTEGER NOT NULL CHECK (CatF07GDollars >= 0),
   CatF07NGDollars INTEGER NOT NULL CHECK (CatF07NGDollars >= 0),
   CatF07Orders INTEGER NOT NULL CHECK (CatF07Orders >= 0),
   CatF07Lines INTEGER NOT NULL CHECK (CatF07Lines >= 0),
   CatS07GDollars INTEGER NOT NULL CHECK (CatS07GDollars >= 0),
   CatS07NGDollars INTEGER NOT NULL CHECK (CatS07NGDollars >= 0),
   CatS07Orders INTEGER NOT NULL CHECK (CatS07Orders >= 0),
   CatS07Lines INTEGER NOT NULL CHECK (CatS07Lines >= 0),
   CatF06GDollars INTEGER NOT NULL CHECK (CatF06GDollars >= 0),
   CatF06NGDollars INTEGER NOT NULL CHECK (CatF06NGDollars >= 0),
   CatF06Orders INTEGER NOT NULL CHECK (CatF06Orders >= 0),
   CatF06Lines INTEGER NOT NULL CHECK (CatF06Lines >= 0),
   CatS06GDollars INTEGER NOT NULL CHECK (CatS06GDollars >= 0),
   CatS06NGDollars INTEGER NOT NULL CHECK (CatS06NGDollars >= 0),
   CatS06Orders INTEGER NOT NULL CHECK (CatS06Orders >= 0),
   CatS06Lines INTEGER NOT NULL CHECK (CatS06Lines >= 0),
   CatF05GDollars INTEGER NOT NULL CHECK (CatF05GDollars >= 0),
   CatF05NGDollars INTEGER NOT NULL CHECK (CatF05NGDollars >= 0),
   CatF05Orders INTEGER NOT NULL CHECK (CatF05Orders >= 0),
   CatF05Lines INTEGER NOT NULL CHECK (CatF05Lines >= 0),
   CatS05GDollars INTEGER NOT NULL CHECK (CatS05GDollars >= 0),
   CatS05NGDollars INTEGER NOT NULL CHECK (CatS05NGDollars >= 0),
   CatS05Orders INTEGER NOT NULL CHECK (CatS05Orders >= 0),
   CatS05Lines INTEGER NOT NULL CHECK (CatS05Lines >= 0),
   CatF04GDollars INTEGER NOT NULL CHECK (CatF04GDollars >= 0),
   CatF04NGDollars INTEGER NOT NULL CHECK (CatF04NGDollars >= 0),
   CatF04Orders INTEGER NOT NULL CHECK (CatF04Orders >= 0),
   CatF04Lines INTEGER NOT NULL CHECK (CatF04Lines >= 0),
   CatS04GDollars INTEGER NOT NULL CHECK (CatS04GDollars >= 0),
   CatS04NGDollars INTEGER NOT NULL CHECK (CatS04NGDollars >= 0),
   CatS04Orders INTEGER NOT NULL CHECK (CatS04Orders >= 0),
   CatS04Lines INTEGER NOT NULL CHECK (CatS04Lines >= 0),
   CatPre04GDollars INTEGER NOT NULL CHECK (CatPre04GDollars >= 0),
   CatPre04NGDollars INTEGER NOT NULL CHECK (CatPre04NGDollars >= 0),
   CatPre04Orders INTEGER NOT NULL CHECK (CatPre04Orders >= 0),
   CatPre04Lines INTEGER NOT NULL CHECK (CatPre04Lines >= 0),
   CatPre04Recency SMALLINT NOT NULL CHECK (CatPre04Recency >= 0 AND CatPre04Recency <= 99),
   EmailsF07 INTEGER NOT NULL CHECK (EmailsF07 >= 0),
   EmailsS07 INTEGER NOT NULL CHECK (EmailsS07 >= 0),
   EmailsF06 INTEGER NOT NULL CHECK (EmailsF06 >= 0),
   EmailsS06 INTEGER NOT NULL CHECK (EmailsS06 >= 0),
   EmailsF05 INTEGER NOT NULL CHECK (EmailsF05 >= 0),
   EmailsS05 INTEGER NOT NULL CHECK (EmailsS05 >= 0),
   CatCircF07 INTEGER NOT NULL CHECK (CatCircF07 >= 0),
   CatCircS07 INTEGER NOT NULL CHECK (CatCircS07 >= 0),
   CatCircF06 INTEGER NOT NULL CHECK (CatCircF06 >= 0),
   CatCircS06 INTEGER NOT NULL CHECK (CatCircS06 >= 0),
   CatCircF05 INTEGER NOT NULL CHECK (CatCircF05 >= 0),
   CatCircS05 INTEGER NOT NULL CHECK (CatCircS05 >= 0),
   GiftRecF07 INTEGER NOT NULL CHECK (GiftRecF07 >= 0),
   GiftRecS07 INTEGER NOT NULL CHECK (GiftRecS07 >= 0),
   GiftRecF06 INTEGER NOT NULL CHECK (GiftRecF06 >= 0),
   GiftRecS06 INTEGER NOT NULL CHECK (GiftRecS06 >= 0),
   GiftRecF05 INTEGER NOT NULL CHECK (GiftRecF05 >= 0),
   GiftRecS05 INTEGER NOT NULL CHECK (GiftRecS05 >= 0),
   GiftRecF04 INTEGER NOT NULL CHECK (GiftRecF04 >= 0),
   GiftRecS04 INTEGER NOT NULL CHECK (GiftRecS04 >= 0),
   GiftRecPre04 INTEGER NOT NULL CHECK (GiftRecPre04 >= 0),
   NewGRF07 INTEGER NOT NULL CHECK (NewGRF07 >= 0),
   NewGRS07 INTEGER NOT NULL CHECK (NewGRS07 >= 0),
   NewGRF06 INTEGER NOT NULL CHECK (NewGRF06 >= 0),
   NewGRS06 INTEGER NOT NULL CHECK (NewGRS06 >= 0),
   NewGRF05 INTEGER NOT NULL CHECK (NewGRF05 >= 0),
   NewGRS05 INTEGER NOT NULL CHECK (NewGRS05 >= 0),
   NewGRF04 INTEGER NOT NULL CHECK (NewGRF04 >= 0), 
   NewGRS04 INTEGER NOT NULL CHECK (NewGRS04 >= 0), 
   NewGRPre04 INTEGER NOT NULL CHECK (NewGRPre04 >= 0), 
   FirstYYMM INTEGER NOT NULL CHECK (FirstYYMM >= 0), 
   FirstChannel CHAR(3) CHECK (FirstChannel IN ('Ret', 'Int', 'Cat')), 
   FirstDollar INTEGER NOT NULL CHECK (FirstDollar >= 0), 
   StoreDist DECIMAL(7, 2) CHECK (StoreDist >= 0), 
   AcqDate INTEGER NOT NULL CHECK (AcqDate >= 0), 
   Email CHAR(1) CHECK (Email IN ('Y', 'N')), 
   OccupCd SMALLINT CHECK (OccupCd >= 0), 
   Travel CHAR(1) CHECK (Travel IN ('Y', 'N')), 
   CurrAff CHAR(1) CHECK (CurrAff IN ('Y', 'N')), 
   CurrEv CHAR(1) CHECK (CurrEv IN ('Y', 'N')), 
   Wines CHAR(1) CHECK (Wines IN ('Y', 'N')), 
   FineArts CHAR(1) CHECK (FineArts IN ('Y', 'N')), 
   Exercise CHAR(1) CHECK (Exercise IN ('Y', 'N')), 
   SelfHelp CHAR(1) CHECK (SelfHelp IN ('Y', 'N')), 
   Collect CHAR(1) CHECK (Collect IN ('Y', 'N')), 
   Needle CHAR(1) CHECK (Needle IN ('Y', 'N')), 
   Sewing CHAR(1) CHECK (Sewing IN ('Y', 'N')), 
   DogOwner CHAR(1) CHECK (DogOwner IN ('Y', 'N')), 
   CarOwner CHAR(1) CHECK (CarOwner IN ('Y', 'N')), 
   Cooking CHAR(1) CHECK (Cooking IN ('Y', 'N')), 
   Pets CHAR(1) CHECK (Pets IN ('Y', 'N')), 
   Fashion CHAR(1) CHECK (Fashion IN ('Y', 'N')), 
   Camping CHAR(1) CHECK (Camping IN ('Y', 'N')), 
   Hunting CHAR(1) CHECK (Hunting IN ('Y', 'N')), 
   Boating CHAR(1) CHECK (Boating IN ('Y', 'N')), 
   AgeCode SMALLINT CHECK (AgeCode >= 0), 
   IncCode SMALLINT CHECK (IncCode >= 0), 
   HomeCode SMALLINT CHECK (HomeCode >= 0), 
   Child0_2 CHAR(1) CHECK (Child0_2 IN ('Y', 'N')), 
   Child3_5 CHAR(1) CHECK (Child3_5 IN ('Y', 'N')), 
   Child6_11 CHAR(1) CHECK (Child6_11 IN ('Y', 'N')), 
   Child12_16 CHAR(1) CHECK (Child12_16 IN ('Y', 'N')), 
   Child17_18 CHAR(1) CHECK (Child17_18 IN ('Y', 'N')), 
   Dwelling SMALLINT CHECK (Dwelling >= 0), 
   LengthRes SMALLINT CHECK (LengthRes >= 0), 
   HomeValue BIGINT CHECK (HomeValue >= 0)
);

COPY 
   Summary 
FROM 
   'D:\\Imperial MSc\\Electives\\Digital Marketing Analytics\\HW1 Data set\\Digital Marketing HW1 data set\\DMEFExtractSummaryV01.CSV' 
WITH
   NULL AS ' '
   DELIMITER ',' 
   CSV HEADER;


-- Load Contacts Table
CREATE TABLE Contacts(
   CustID INTEGER NOT NULL REFERENCES Summary(CustID), 
   ContactDate DATE NOT NULL, 
   ContactType CHAR(1) NOT NULL CHECK (ContactType IN ('C', 'E'))
);

CREATE INDEX ON Contacts(CustID);

COPY 
   Contacts 
FROM 
   'D:\\Imperial MSc\\Electives\\Digital Marketing Analytics\\HW1 Data set\\Digital Marketing HW1 data set\\DMEFExtractContactsV01.CSV' 
WITH
   NULL AS ' '
   DELIMITER ',' 
   CSV HEADER;

-- Load Orders Table
CREATE TABLE Orders(
   CustID INTEGER NOT NULL REFERENCES Summary(CustID), 
   OrderNo BIGINT NOT NULL, 
   OrderDate DATE NOT NULL, 
   OrderMethod VARCHAR(2) NOT NULL CHECK (OrderMethod IN ('ST', 'I', 'P', 'M')), 
   PaymentType CHAR(2) NOT NULL CHECK (PaymentType IN ('BC', 'CA', 'CK', 'GC', 'HA', 'NV', 'PC')), 
   PRIMARY KEY (CustID, OrderNo, OrderDate)
);

CREATE INDEX ON Orders(CustID);

COPY 
   Orders 
FROM 
   'D:\\Imperial MSc\\Electives\\Digital Marketing Analytics\\HW1 Data set\\Digital Marketing HW1 data set\\DMEFExtractOrdersV01.CSV' 
WITH
   NULL AS ' '
   DELIMITER ',' 
   CSV HEADER;

-- Load Lines Table
CREATE TABLE Lines(
   CustID INTEGER NOT NULL, 
   OrderNo BIGINT NOT NULL, 
   OrderDate DATE NOT NULL, 
   LineDollar DECIMAL(9, 2) NOT NULL CHECK (LineDollar >= 0), 
   Gift CHAR(1) CHECK (Gift IN ('Y', 'N')), 
   RecipNo INTEGER CHECK (RecipNo > 0), 
   FOREIGN KEY (CustID, OrderNo, OrderDate) REFERENCES Orders(CustID, OrderNo, OrderDate)
);

CREATE INDEX ON Lines(CustID);

COPY 
   Lines 
FROM 
   'D:\\Imperial MSc\\Electives\\Digital Marketing Analytics\\HW1 Data set\\Digital Marketing HW1 data set\\DMEFExtractLinesV01.CSV' 
WITH
   NULL AS ' '
   DELIMITER ',' 
   CSV HEADER;


