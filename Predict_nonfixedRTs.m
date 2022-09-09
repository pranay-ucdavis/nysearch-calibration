clc
clear all
close all

%----------------Filtering parameters (needs to be verfied with AIMS for specific data)---------------------%
%----------------Filtering parameters (needs to be verfied with AIMS for specific data)---------------------%
valALSLambda=1e6; % Asymmetric Least Squares Function parameters: smoothing parameter 1e2 to 1e9
valALSProportionPositiveResiduals=0.01; % Asymmetric Least Squares Function parameters: asymmetry parameter 0.001 to 0.01
valSGWindowSize=21; % Savitzky-Golay filter parameter: Frame/Window length
valSGMOrder=7; % Savitzky-Golay filter parameter: Polynomial order
%------------------------------------------------------------------------------------------------------------%
%------------------------------------------------------------------------------------------------------------%
RTrange = [401	448	563	719	824	1322;346 392 507 661	755	1307];
deltaRT = 15;
mylegends = [];
allpeaks = {};
j = 1;
[file,path] = uigetfile('*_Pos.xls');
filename = [path file];
format long g
[ Vc, timeStamp, amplitude ] = DMSRead(filename);
tempMat = amplitude;
RTs_model1 = [0.7907, 0.575, 0.5905, 0.5097, 0.5497, 0.6076; -0.0113, -0.3948, -0.1992, -0.1818, -0.1526, -0.6909]'; % IPM TBM
CVvalue=0;
valMinCV = CVvalue-1;
valMaxCV = CVvalue+1;

indxMinCV = find(Vc>valMinCV, 1, 'first');
indxMaxCV = find(Vc<valMaxCV, 1, 'last');
Z = tempMat(:,indxMinCV:indxMaxCV);
size_z = size(Z);

for kk =1:1:size_z(1,1)
        mydata(kk,1) = sum(Z(kk,:));
end
    
    
baseline_xx= 70:1:300;
baseline_yy = mydata(baseline_xx,1);
baseline_xx = baseline_xx';
    
x_forfit = [ones(length(baseline_xx'),1) baseline_xx]; % baseline_xx';
y_forfit = baseline_yy;
fitting_parameters = x_forfit\y_forfit;
    
    mydata_size = size(mydata);
    x_all = 1:1:mydata_size(1,1);
    y_fitted = fitting_parameters(1,1) + fitting_parameters(2,1)*x_all;
    mydata = mydata - y_fitted';
    mydata = mydata(1:1350,1);
    x_all = 1:1:1350;
    mydata = movmean(mydata,10);  
   [pks,locs,widths,proms]=findpeaks(mydata,x_all,'MinPeakProminence',.1,'Annotate','extents','WidthReference','halfheight');
   p = length(locs);
   q = 0;
    while p ~= q
        q = p;
        locs(find(diff(locs)<30, 1) + 1) = [];
        p = length(locs);
    end
   locs1 = locs( locs< 850);
   locs2= locs( locs>=1300);
   locs = [locs1 locs2];
   allpeaks{j,1} = file;
   allpeaks{j,2} = locs;

 localpeakindex = 3;
 for k =1:1:6
     if length(locs)>=k && locs(1,k) >= RTrange(2,k) && locs(1,k)<=RTrange(1,k)
            valMinRT = locs(1,k) - deltaRT;
            valMaxRT = locs(1,k) + deltaRT;
            tempdata = mydata(valMinRT:valMaxRT,1);
            tempdata = sort(tempdata,'descend');
            III = sum(tempdata(1:5,1));
            allpeaks{j,localpeakindex} = III;
            localpeakindex = localpeakindex+1;
            Totalconcentration(k,1) = III*RTs_model1(k,1)+ RTs_model1(k,2);
     else
         Totalconcentration(k,1) = 0;
         
     end 

 end

 


Totalconcentration(Totalconcentration < 0.1) = 0;
Totalconcentration(Totalconcentration > 5) = 5;


ETM = Totalconcentration(1,1);
DMS = Totalconcentration(2,1);
NPM = Totalconcentration(3,1);
IPM = Totalconcentration(4,1);
TBM = Totalconcentration(5,1);
THT = Totalconcentration(6,1);




prompt = {'Have you closed all excel sheet? (y or n)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'y'};
input_user = inputdlg(prompt,dlgtitle,dims,definput);


%----------------Just print and save-------------------%
if input_user{1,1} == 'y'
    if isfile('data.xlsx')

        mycurrent_time = datetime('now','Format','d-MMM-y HH:mm:ss Z');
        mycurrent_time = datestr(mycurrent_time);

        mydata = {file,mycurrent_time,ETM,DMS,NPM,IPM,TBM,THT};
        [numbers, strings, raw] = xlsread('data.xlsx');
        lastRow = size(raw, 1);
        nextRow = lastRow + 1;
        cellReference = sprintf('A%d', nextRow);
        xlswrite('data.xlsx', mydata, 'Sheet1', cellReference);
    else
        mycurrent_time = datetime('now','Format','d-MMM-y HH:mm:ss Z');
        mycurrent_time = datestr(mycurrent_time);

        myheader = {'Sample name','Date and TIme','ETM','DMS','NPM','IPM','TBT','THT'};
        xlswrite('data.xlsx',myheader);

        [numbers, strings, raw] = xlsread('data.xlsx');
        lastRow = size(raw, 1);
        nextRow = lastRow + 1;

        mydata = {file,mycurrent_time,ETM,DMS,NPM,IPM,TBM,THT};

        cellReference = sprintf('A%d', nextRow);
        xlswrite('data.xlsx', mydata, 'Sheet1', cellReference);
    end
end

checkchemicals = ["ETM";"DMS";"NPM";"IPM";"TBM";"THT"];%,"DMS","NPM","IPM"];
Chemical_concentration = [ETM;DMS;NPM;IPM;TBM;THT];

concentrationresult = table(checkchemicals,Chemical_concentration);

fig = uifigure('Position',[100 100 752 250]);
uit = uitable('Parent',fig,'Position',[25 50 700 200]);
uit.Data = concentrationresult;




