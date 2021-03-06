function permuteGlobalStats_longbetween_1g (nperm)
% Shelli Kesler May 2020
% longitudinal permutation testing for global properties
% run GAT 4 groups first with G1T1, G1T2, G2T1, G2T2
% run this script from AUC_Results folder


%-----Enter info here-------------
FileSaveSuffix = 'long_global';
Meas = {'MClust','MDeg','Trans','Assort','GEff','MLocEff','Mod','PathL','Lambda','Gamma','Sigma','MEdgeBetw','MNodeBetw'}; % Measures of interest
%---------------------------------

load('AUC_NetMesPerDens_AveAcrossDens.mat')

for i = 1:length(Meas)
    slopeG1(i,:) = nanmean(eval(['auc_' Meas{i} '_2']) - eval(['auc_' Meas{i} '_1']));
end

trueDiff = slopeG1;
trueDiffabs= abs(slopeG1);

for i = 1:nperm
    for j = 1:length(Meas)
        randSlope1(j,i) = nanmean(eval(['auc_' Meas{j} '_2_rand' '(:,:,i)']) - eval(['auc_' Meas{j} '_1_rand' '(:,:,i)']));
    end
end

randDiff = abs(randSlope1);

for i = 1:length(Meas)
    pVal(i,:) = mean(randDiff(i,:) > trueDiffabs(i,:));
end

[~, FDRcritP, pValFDR]=fdr_bh(pVal);

% calculate the 95% confidence intervals
lolim = .025*nperm;
hilim = nperm-lolim;
for i = 1:length(Meas)
    confint(i,:) = sort(randDiff(i,:));
    CI(i,1) = confint(i,lolim);
    CI(i,2) = confint(i,hilim);
end

rownames = {'MClust','MDegree','Trans','Assort','Eglob','MEloc','Mod','PathL','Lambda','Gamma','Sigma','MEdgeBtwn','MNodeBtwn'}'; %names of measures
colnames = {'meanDiff','LL','UL','p','pFDR'};

temp = cat(2,trueDiff,CI,pVal,pValFDR);
resultsTable = array2table(temp,'VariableNames',colnames,'RowNames',rownames);

save(['PermStats_' FileSaveSuffix], 'trueDiff', 'trueDiffabs','randDiff',...
    'pVal','pValFDR','CI','FDRcritP', 'resultsTable');

writetable(resultsTable,['resultsTable_' FileSaveSuffix '.xlsx'],'WriteRowNames',true)