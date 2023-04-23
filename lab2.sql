--4
use MyDb;
#请在以下空白处填写适当的诘句，实现编程要求。
--(1) 为表Staff添加主码
ALTER TABLE Staff ADD PRIMARY KEY(staffNo);
--(2) Dept.mgrStaffNo是外码，对应的主码是Staff.staffNo,请添加这个外码，名字为 FK_Dept_mgrStaffNo:
ALTER TABLE Dept ADD CONSTRAINT FK_Dept_mgrStaffNo FOREIGN KEY(mgrStaffNo) references Staff(StaffNo);
--(3) Staff.dept 是外码，对应的主码是Dept.deptNo. 请添加这个外码，名字为 FK_Staff_dept:
ALTER TABLE Staff ADD CONSTRAINT FK_Staff_dept FOREIGN KEY(dept) references Dept(deptNo) ;

--(4) 为表Staff 添加check约束，规则为：gender的值只能为F或M；约束名为 CK_Staff_gender:
ALTER TABLE Staff ADD CONSTRAINT CK_Staff_gender check(gender in ('M','F'));
--(5) 为表Dept添加unique约束：deptName不允许重复。约束名为 UN_Dept_deptName：
alter table Dept ADD CONSTRAINT UN_Dept_deptName UNIQUE(deptName);

--3
ALTER TABLE addressBook modify QQ char(12);
ALTER TABLE addressBook RENAME COLUMN weixin TO wechat;

--2
#语句1：删除表orderDetail中的列orderDate
ALTER TABLE orderDetail DROP COLUMN orderDate;
#语句2：添加列unitPrice
ALTER TABLE orderDetail ADD COLUMN  unitPrice numeric(10,2);

--1
ALTER TABLE your_table AS mytable;