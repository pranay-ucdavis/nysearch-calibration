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
deltaRT = 15;



figure 
hold on
files = dir('C:\Users\chakr\OneDrive\Desktop\NYSEARCH\2022_09_07_Stephanie\2022_09_07_Stephanie\data/*.xls');
mylegends = [];

allpeaks = {};

j = 1;
for file = files'
    S1 = file.folder;
    S2 = file.name;
    filename = [S1 '/' S2]
    format long g
    [ Vc, timeStamp, amplitude ] = DMSRead(filename);
    tempMat = amplitude;
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
    
    newStr = erase( S2 ,'_');
    newStr = erase( newStr ,'mercaptans');
    newStr = erase( newStr ,'Pos.xls'); 
    baseline_xx= 30:1:250;
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
    mydata = movmean(mydata,15);
    plot(mydata,'DisplayName',newStr) 
    [pks,locs,widths,proms]=findpeaks(mydata,x_all,'MinPeakProminence',.09,'Annotate','extents','WidthReference','halfheight')
    p = length(locs);
    q = 0;
    while p ~= q
        q = p;
        locs(find(diff(locs)<30, 1) + 1) = [];
        p = length(locs);
    end
%    locs = locs(locs>200);
   locs1 = locs( locs< 850);
   locs2= locs( locs>=1300);
   locs = [locs1 locs2];
   if length(locs)< 6
       locs = [341 locs];
   end
   allpeaks{j,1} = file.name;
   allpeaks{j,2} = locs;

 localpeakindex = 3;
 for k =1:1:6
     valMinRT = locs(1,k) -deltaRT;
     valMaxRT = locs(1,k)+ deltaRT;
     disp(file.name)
     tempdata = mydata(valMinRT:valMaxRT,1);
     tempdata = sort(tempdata,'descend')
     III = sum(tempdata(1:7,1));
     allpeaks{j,localpeakindex} = III;
     localpeakindex = localpeakindex+1;
 end
 j = j+1;
 
end
legend
% xlim([200 1400])
set(gca,'FontSize',18)
box on




